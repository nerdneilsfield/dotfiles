#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  ./examples/auto_profile.sh [options] -- <app> [args...]
  ./examples/auto_profile.sh --import <report.ncu-rep> [options]

Modes:
  --mode quick       SpeedOfLight + LaunchStats + Occupancy
  --mode memory      quick + MemoryWorkloadAnalysis + MemoryWorkloadAnalysis_Tables
  --mode scheduler   quick + SchedulerStats + WarpStateStats + SourceCounters
  --mode full        --set full
  --import FILE      Import an existing .ncu-rep instead of re-running the app

Options:
  -o, --output-prefix NAME     Output prefix. Default: mode or report-based timestamped name
  --report-dir DIR             Output directory. Default: ncu_reports
  --kernel-regex REGEX         Filter kernels with -k regex:<REGEX>
  -s, --launch-skip N          Skip N launches before profiling
  -c, --launch-count N         Profile at most N launches
  --nvtx-include EXPR          Add one NVTX include expression. Repeatable
  --target-processes MODE      application-only or all. Default: application-only
  --cache-control MODE         all or none. Default: all
  --clock-control MODE         Optional ncu --clock-control value
  --ncu-arg ARG                Append one extra raw ncu option. Repeatable
  --help                       Show this message

Examples:
  ./examples/auto_profile.sh --mode quick --kernel-regex 'matmul.*' -s 5 -c 1 -- ./build/matmul
  ./examples/auto_profile.sh --mode memory --target-processes all -- ./launcher
  ./examples/auto_profile.sh --import ncu_reports/baseline.ncu-rep -o baseline
EOF
}

ensure_ncu() {
    if command -v ncu >/dev/null 2>&1; then
        return
    fi

    if [ -x "/usr/local/cuda/bin/ncu" ]; then
        export PATH="/usr/local/cuda/bin:$PATH"
        return
    fi

    echo "Error: ncu not found in PATH." >&2
    exit 1
}

section_args_for_mode() {
    case "$1" in
        quick)
            printf '%s\n' \
                "--section" "SpeedOfLight" \
                "--section" "LaunchStats" \
                "--section" "Occupancy"
            ;;
        memory)
            printf '%s\n' \
                "--section" "SpeedOfLight" \
                "--section" "LaunchStats" \
                "--section" "Occupancy" \
                "--section" "MemoryWorkloadAnalysis" \
                "--section" "MemoryWorkloadAnalysis_Tables"
            ;;
        scheduler)
            printf '%s\n' \
                "--section" "SpeedOfLight" \
                "--section" "LaunchStats" \
                "--section" "Occupancy" \
                "--section" "SchedulerStats" \
                "--section" "WarpStateStats" \
                "--section" "SourceCounters"
            ;;
        full)
            printf '%s\n' "--set" "full"
            ;;
        *)
            echo "Error: unsupported mode '$1'" >&2
            exit 1
            ;;
    esac
}

quote_cmd() {
    local out=()
    local arg
    for arg in "$@"; do
        out+=("$(printf '%q' "$arg")")
    done
    printf '%s\n' "${out[*]}"
}

log_cmd() {
    local cmd_text
    cmd_text=$(quote_cmd "$@")
    echo "$cmd_text" | tee -a "$COMMANDS_FILE"
}

run_capture_stdout() {
    local output_file=$1
    shift
    log_cmd "$@"
    "$@" >"$output_file" 2>>"$STDERR_LOG"
}

run_capture_combined() {
    local output_file=$1
    shift
    log_cmd "$@"
    "$@" 2>&1 | tee "$output_file"
}

MODE="quick"
IMPORT_FILE=""
OUTPUT_PREFIX=""
REPORT_DIR="ncu_reports"
KERNEL_REGEX=""
LAUNCH_SKIP=""
LAUNCH_COUNT=""
TARGET_PROCESSES="application-only"
CACHE_CONTROL="all"
CLOCK_CONTROL=""
APP_CMD=()
EXTRA_NCU_ARGS=()
NVTX_INCLUDES=()

while [ $# -gt 0 ]; do
    case "$1" in
        --mode)
            MODE=$2
            shift 2
            ;;
        --import)
            MODE="import"
            IMPORT_FILE=$2
            shift 2
            ;;
        -o|--output-prefix)
            OUTPUT_PREFIX=$2
            shift 2
            ;;
        --report-dir)
            REPORT_DIR=$2
            shift 2
            ;;
        --kernel-regex)
            KERNEL_REGEX=$2
            shift 2
            ;;
        -s|--launch-skip)
            LAUNCH_SKIP=$2
            shift 2
            ;;
        -c|--launch-count)
            LAUNCH_COUNT=$2
            shift 2
            ;;
        --nvtx-include)
            NVTX_INCLUDES+=("$2")
            shift 2
            ;;
        --target-processes)
            TARGET_PROCESSES=$2
            shift 2
            ;;
        --cache-control)
            CACHE_CONTROL=$2
            shift 2
            ;;
        --clock-control)
            CLOCK_CONTROL=$2
            shift 2
            ;;
        --ncu-arg)
            EXTRA_NCU_ARGS+=("$2")
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        --)
            shift
            APP_CMD=("$@")
            break
            ;;
        *)
            echo "Error: unknown argument '$1'" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [ "$MODE" = "import" ]; then
    if [ -z "$IMPORT_FILE" ]; then
        echo "Error: --import requires a .ncu-rep file." >&2
        exit 1
    fi
else
    if [ ${#APP_CMD[@]} -eq 0 ]; then
        echo "Error: target application must be provided after '--'." >&2
        exit 1
    fi
fi

ensure_ncu
mkdir -p "$REPORT_DIR"

if [ -z "$OUTPUT_PREFIX" ]; then
    if [ "$MODE" = "import" ]; then
        OUTPUT_PREFIX="$(basename "${IMPORT_FILE%.ncu-rep}")"
    else
        OUTPUT_PREFIX="${MODE}_$(date +%Y%m%d_%H%M%S)"
    fi
fi

REPORT_BASE="${REPORT_DIR}/${OUTPUT_PREFIX}"
REPORT_FILE="${REPORT_BASE}.ncu-rep"
RAW_CSV="${REPORT_BASE}_raw.csv"
SUMMARY_TXT="${REPORT_BASE}_summary.txt"
DETAILS_TXT="${REPORT_BASE}_details.txt"
ANALYSIS_MD="${REPORT_BASE}_analysis.md"
PROFILE_LOG="${REPORT_BASE}_profile.log"
STDERR_LOG="${REPORT_BASE}_stderr.log"
COMMANDS_FILE="${REPORT_BASE}_commands.txt"

: >"$COMMANDS_FILE"
: >"$STDERR_LOG"

echo "NCU profiling workflow"
echo "  mode: ${MODE}"
echo "  output prefix: ${OUTPUT_PREFIX}"
echo "  report dir: ${REPORT_DIR}"

if [ "$MODE" = "import" ]; then
    REPORT_FILE="$IMPORT_FILE"
    echo "  import file: ${IMPORT_FILE}"
else
    echo "  target command: $(quote_cmd "${APP_CMD[@]}")"
fi

if [ -n "$KERNEL_REGEX" ]; then
    echo "  kernel regex: ${KERNEL_REGEX}"
fi

NCU_CMD=(ncu --force-overwrite -o "$REPORT_BASE")

if [ "$MODE" != "import" ]; then
    while IFS= read -r arg; do
        NCU_CMD+=("$arg")
    done < <(section_args_for_mode "$MODE")

    NCU_CMD+=(--target-processes "$TARGET_PROCESSES")
    NCU_CMD+=(--cache-control "$CACHE_CONTROL")

    if [ -n "$CLOCK_CONTROL" ]; then
        NCU_CMD+=(--clock-control "$CLOCK_CONTROL")
    fi

    if [ -n "$KERNEL_REGEX" ]; then
        NCU_CMD+=(-k "regex:${KERNEL_REGEX}")
    fi

    if [ -n "$LAUNCH_SKIP" ]; then
        NCU_CMD+=(-s "$LAUNCH_SKIP")
    fi

    if [ -n "$LAUNCH_COUNT" ]; then
        NCU_CMD+=(-c "$LAUNCH_COUNT")
    fi

    if [ ${#NVTX_INCLUDES[@]} -gt 0 ]; then
        NCU_CMD+=(--nvtx)
        for expr in "${NVTX_INCLUDES[@]}"; do
            NCU_CMD+=(--nvtx-include "$expr")
        done
    fi

    if [ ${#EXTRA_NCU_ARGS[@]} -gt 0 ]; then
        NCU_CMD+=("${EXTRA_NCU_ARGS[@]}")
    fi

    NCU_CMD+=("${APP_CMD[@]}")
    run_capture_combined "$PROFILE_LOG" "${NCU_CMD[@]}"
fi

run_capture_stdout "$SUMMARY_TXT" \
    ncu --import "$REPORT_FILE" --print-summary per-kernel

run_capture_stdout "$DETAILS_TXT" \
    ncu --import "$REPORT_FILE" --page details

run_capture_stdout "$RAW_CSV" \
    ncu --import "$REPORT_FILE" --page raw --csv --print-units base

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/ncu_analyzer.py" ]; then
    ANALYZER_CMD=(
        python3 "${SCRIPT_DIR}/ncu_analyzer.py"
        --csv "$RAW_CSV"
        --summary-file "$SUMMARY_TXT"
        --report-file "$REPORT_FILE"
        -o "$ANALYSIS_MD"
    )

    if [ -n "$KERNEL_REGEX" ]; then
        ANALYZER_CMD+=(--kernel-regex "$KERNEL_REGEX")
    fi

    log_cmd "${ANALYZER_CMD[@]}"
    "${ANALYZER_CMD[@]}" >>"$STDERR_LOG" 2>&1 || {
        echo "Warning: analyzer failed. See ${STDERR_LOG}" >&2
    }
fi

echo
echo "Artifacts"
echo "  report:   ${REPORT_FILE}"
echo "  summary:  ${SUMMARY_TXT}"
echo "  details:  ${DETAILS_TXT}"
echo "  raw csv:  ${RAW_CSV}"
echo "  stderr:   ${STDERR_LOG}"
echo "  commands: ${COMMANDS_FILE}"
if [ -f "$PROFILE_LOG" ]; then
    echo "  profile:  ${PROFILE_LOG}"
fi
if [ -f "$ANALYSIS_MD" ]; then
    echo "  analysis: ${ANALYSIS_MD}"
fi

echo
echo "Next commands"
echo "  ncu --import ${REPORT_FILE} --print-summary per-kernel"
echo "  ncu --import ${REPORT_FILE} --page raw --csv --print-units base > ${OUTPUT_PREFIX}_raw.csv"
