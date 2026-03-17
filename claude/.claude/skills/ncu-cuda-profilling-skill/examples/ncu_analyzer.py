#!/usr/bin/env python3

import argparse
import csv
import json
import re
import subprocess
import tempfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple


LIBRARY_KERNEL_HINTS = ("cublas", "cutlass", "cudnn", "nccl", "nvshmem")

METRIC_ALIASES = {
    "sm_throughput": ("compute (sm) throughput", "sm throughput"),
    "memory_throughput": ("memory throughput",),
    "dram_throughput": ("dram throughput",),
    "l1tex_throughput": ("l1/tex cache throughput", "l1tex throughput"),
    "l2_throughput": ("l2 cache throughput", "l2 throughput"),
    "sm_busy": ("sm busy",),
    "achieved_occupancy": ("achieved occupancy", "occupancy"),
    "theoretical_occupancy": ("theoretical occupancy",),
    "duration": ("duration", "gpu time duration"),
    "block_size": ("block size",),
    "grid_size": ("grid size",),
    "registers_per_thread": ("registers per thread",),
    "eligible_warps_per_scheduler": ("eligible warps per scheduler",),
    "issued_warps_per_scheduler": ("issued warp per scheduler", "issued warps per scheduler"),
}

METRIC_DISPLAY = {
    "sm_throughput": "SM Throughput",
    "memory_throughput": "Memory Throughput",
    "dram_throughput": "DRAM Throughput",
    "l1tex_throughput": "L1/TEX Throughput",
    "l2_throughput": "L2 Throughput",
    "sm_busy": "SM Busy",
    "achieved_occupancy": "Achieved Occupancy",
    "theoretical_occupancy": "Theoretical Occupancy",
    "duration": "Duration",
    "block_size": "Block Size",
    "grid_size": "Grid Size",
    "registers_per_thread": "Registers / Thread",
    "eligible_warps_per_scheduler": "Eligible Warps / Scheduler",
    "issued_warps_per_scheduler": "Issued Warps / Scheduler",
}

DEFAULT_NEXT_COMMANDS = {
    "memory": "ncu --section SpeedOfLight --section LaunchStats --section Occupancy --section MemoryWorkloadAnalysis --section MemoryWorkloadAnalysis_Tables -o memory_dive -- ./your_app",
    "scheduler": "ncu --section SpeedOfLight --section LaunchStats --section Occupancy --section SchedulerStats --section WarpStateStats --section SourceCounters -o scheduler_dive -- ./your_app",
    "compare": "ncu --import profile.ncu-rep --page raw --csv --print-units base > profile_raw.csv",
}


@dataclass
class Diagnosis:
    title: str
    confidence: str
    evidence: List[str]
    uncertainty: List[str]
    next_command: str
    code_experiments: List[str] = field(default_factory=list)


def parse_first_float(value: str) -> Optional[float]:
    if value is None:
        return None
    text = value.strip()
    if not text or text.lower() in {"n/a", "nan", "inf", "-inf"}:
        return None

    candidate = text.split(";")[0].strip()
    match = re.search(r"[-+]?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?", candidate)
    if not match:
        return None
    try:
        return float(match.group(0))
    except ValueError:
        return None


def normalize_name(name: str) -> str:
    return re.sub(r"\s+", " ", name.strip().lower())


class RawCsvParser:
    def __init__(self) -> None:
        self.kernel_metrics: Dict[str, Dict[str, float]] = {}

    def parse(self, path: Path) -> Dict[str, Dict[str, float]]:
        current_kernel = "all-kernels"
        header: Optional[Dict[str, int]] = None

        with path.open(newline="", encoding="utf-8", errors="replace") as handle:
            reader = csv.reader(handle)
            for row in reader:
                cells = [cell.strip() for cell in row]
                compact = [cell for cell in cells if cell]
                if not compact:
                    continue

                lowered = [cell.lower() for cell in compact]
                if "metric name" in lowered and ("metric value" in lowered or "aggregate value" in lowered):
                    header = self._make_header(cells)
                    continue

                if header is None:
                    if len(compact) == 1 and not compact[0].startswith("==PROF=="):
                        current_kernel = compact[0]
                    elif len(compact) >= 3:
                        metric = compact[0]
                        value = parse_first_float(compact[-1])
                        if value is not None:
                            self.kernel_metrics.setdefault(current_kernel, {})[metric] = value
                    continue

                metric_name = self._pick(cells, header, ("metric name",))
                value_text = self._pick(cells, header, ("metric value", "aggregate value", "value"))
                kernel_name = self._pick(
                    cells,
                    header,
                    ("kernel name", "kernel", "function name", "name"),
                )

                if kernel_name:
                    current_kernel = kernel_name

                if not metric_name:
                    continue

                value = parse_first_float(value_text or "")
                if value is None:
                    continue

                self.kernel_metrics.setdefault(current_kernel, {})[metric_name] = value

        return self.kernel_metrics

    @staticmethod
    def _make_header(row: List[str]) -> Dict[str, int]:
        return {cell.strip().lower(): idx for idx, cell in enumerate(row) if cell.strip()}

    @staticmethod
    def _pick(row: List[str], header: Dict[str, int], candidates: Iterable[str]) -> Optional[str]:
        for candidate in candidates:
            if candidate in header and header[candidate] < len(row):
                value = row[header[candidate]].strip()
                if value:
                    return value
        return None


class SummaryParser:
    def parse(self, text: str) -> Dict[str, Dict[str, float]]:
        kernels: Dict[str, Dict[str, float]] = {}
        current_kernel: Optional[str] = None
        current_section: Optional[str] = None

        for raw_line in text.splitlines():
            line = raw_line.strip()
            if not line:
                continue

            if line.startswith("Section:"):
                current_section = line.removeprefix("Section:").strip()
                continue

            if "Device" in line and "x(" in line and not line.startswith("Metric"):
                current_kernel = line.split("(")[0].strip()
                kernels.setdefault(current_kernel, {})
                current_section = None
                continue

            if current_kernel is None or current_section is None:
                continue

            if line.startswith("|"):
                parts = [part.strip() for part in line.split("|") if part.strip()]
                if len(parts) >= 3:
                    value = parse_first_float(parts[-1])
                    if value is not None:
                        kernels[current_kernel][parts[0]] = value
                continue

            parts = line.split()
            if len(parts) >= 3:
                value = parse_first_float(parts[-1])
                if value is not None:
                    kernels[current_kernel][" ".join(parts[:-2])] = value

        return kernels


class NCUAnalyzer:
    def __init__(
        self,
        kernel_name: Optional[str] = None,
        kernel_regex: Optional[str] = None,
        report_file: Optional[str] = None,
    ) -> None:
        self.kernel_name = kernel_name
        self.kernel_regex = re.compile(kernel_regex) if kernel_regex else None
        self.report_file = report_file
        self.kernels: Dict[str, Dict[str, float]] = {}

    def load(self, csv_file: Optional[str], summary_file: Optional[str], import_file: Optional[str]) -> None:
        if import_file:
            self._load_from_report(import_file)
            self.report_file = import_file
            return

        if csv_file:
            self.kernels = RawCsvParser().parse(Path(csv_file))

        if (not self.kernels or self._all_metrics_empty()) and summary_file:
            parsed = SummaryParser().parse(Path(summary_file).read_text(encoding="utf-8", errors="replace"))
            if parsed:
                self.kernels = parsed

    def analyze(self) -> Tuple[str, Dict[str, float], List[Diagnosis]]:
        if not self.kernels:
            raise RuntimeError("No kernel metrics could be parsed.")

        kernel_name = self._select_kernel()
        standardized = self._standardize(self.kernels[kernel_name])
        diagnoses = self._diagnose(standardized)
        return kernel_name, standardized, diagnoses

    def _load_from_report(self, report_file: str) -> None:
        with tempfile.TemporaryDirectory(prefix="ncu_analyzer_") as temp_dir:
            raw_csv = Path(temp_dir) / "raw.csv"
            summary_txt = Path(temp_dir) / "summary.txt"

            subprocess.run(
                ["ncu", "--import", report_file, "--page", "raw", "--csv", "--print-units", "base"],
                check=True,
                stdout=raw_csv.open("w", encoding="utf-8"),
                stderr=subprocess.DEVNULL,
            )
            subprocess.run(
                ["ncu", "--import", report_file, "--print-summary", "per-kernel"],
                check=True,
                stdout=summary_txt.open("w", encoding="utf-8"),
                stderr=subprocess.DEVNULL,
            )

            self.kernels = RawCsvParser().parse(raw_csv)
            if not self.kernels or self._all_metrics_empty():
                parsed = SummaryParser().parse(summary_txt.read_text(encoding="utf-8", errors="replace"))
                if parsed:
                    self.kernels = parsed

    def _all_metrics_empty(self) -> bool:
        return all(not metrics for metrics in self.kernels.values())

    def _select_kernel(self) -> str:
        names = list(self.kernels.keys())
        if self.kernel_name and self.kernel_name in self.kernels:
            return self.kernel_name

        if self.kernel_regex:
            filtered = [name for name in names if self.kernel_regex.search(name)]
            if filtered:
                names = filtered

        non_library = [name for name in names if not any(hint in name.lower() for hint in LIBRARY_KERNEL_HINTS)]
        if non_library:
            names = non_library

        return names[0]

    def _standardize(self, metrics: Dict[str, float]) -> Dict[str, float]:
        standardized: Dict[str, float] = {}
        for original_name, value in metrics.items():
            name = normalize_name(original_name)
            for target, aliases in METRIC_ALIASES.items():
                if any(alias in name for alias in aliases):
                    standardized[target] = value
        return standardized

    def _diagnose(self, metrics: Dict[str, float]) -> List[Diagnosis]:
        diagnoses: List[Diagnosis] = []
        dram = metrics.get("dram_throughput")
        l1tex = metrics.get("l1tex_throughput")
        l2 = metrics.get("l2_throughput")
        sm = metrics.get("sm_throughput")
        mem = metrics.get("memory_throughput")
        occupancy = metrics.get("achieved_occupancy")
        regs = metrics.get("registers_per_thread")
        eligible = metrics.get("eligible_warps_per_scheduler")
        issued = metrics.get("issued_warps_per_scheduler")

        if dram is not None and dram >= 70:
            evidence = [f"DRAM throughput is {dram:.1f}%."]
            if mem is not None:
                evidence.append(f"Overall memory throughput is {mem:.1f}%.")
            if l2 is not None:
                evidence.append(f"L2 throughput is {l2:.1f}%.")
            diagnoses.append(
                Diagnosis(
                    title="Likely DRAM-side memory pressure",
                    confidence="medium" if l2 is None else "high",
                    evidence=evidence,
                    uncertainty=[
                        "Throughput alone does not prove inefficient access patterns.",
                        "Use MemoryWorkloadAnalysis_Tables to confirm coalescing and cache behavior.",
                    ],
                    next_command=DEFAULT_NEXT_COMMANDS["memory"],
                    code_experiments=[
                        "Try shared-memory tiling or blocking to increase data reuse.",
                        "Check whether global loads can be vectorized safely.",
                        "Inspect memory access pattern for coalescing issues before changing math code.",
                    ],
                )
            )

        if l1tex is not None and l1tex >= 80 and (dram is None or dram < 40):
            diagnoses.append(
                Diagnosis(
                    title="Likely on-chip memory or cache pressure",
                    confidence="medium",
                    evidence=[
                        f"L1/TEX throughput is {l1tex:.1f}%.",
                        f"DRAM throughput is {dram:.1f}%." if dram is not None else "DRAM throughput is unavailable.",
                    ],
                    uncertainty=[
                        "This does not prove bank conflicts by itself.",
                        "Use MemoryWorkloadAnalysis_Tables before making shared-memory layout claims.",
                    ],
                    next_command=DEFAULT_NEXT_COMMANDS["memory"],
                    code_experiments=[
                        "Inspect shared-memory layout and add padding only if table data supports it.",
                        "Check for cache-thrashing or poor data locality before changing launch geometry.",
                    ],
                )
            )

        if occupancy is not None and occupancy < 40:
            evidence = [f"Achieved occupancy is {occupancy:.1f}%."]
            if regs is not None:
                evidence.append(f"Registers per thread is {regs:.1f}.")
            diagnoses.append(
                Diagnosis(
                    title="Possible occupancy or launch-constraint limit",
                    confidence="medium",
                    evidence=evidence,
                    uncertainty=[
                        "Low occupancy can matter, but it is not automatically the root cause.",
                        "Confirm with LaunchStats and scheduler data before reducing registers aggressively.",
                    ],
                    next_command=DEFAULT_NEXT_COMMANDS["compare"],
                    code_experiments=[
                        "Evaluate block size changes with controlled before/after captures.",
                        "Check whether register pressure can be reduced without increasing memory traffic.",
                    ],
                )
            )

        if sm is not None and sm >= 80 and (mem is None or mem < 60):
            diagnoses.append(
                Diagnosis(
                    title="Possible compute-side pressure",
                    confidence="medium",
                    evidence=[
                        f"SM throughput is {sm:.1f}%.",
                        f"Memory throughput is {mem:.1f}%." if mem is not None else "Memory throughput is unavailable.",
                    ],
                    uncertainty=[
                        "This points toward compute pressure, but pipeline-level analysis may still be needed.",
                    ],
                    next_command="ncu --section SpeedOfLight --section ComputeWorkloadAnalysis --section LaunchStats -o compute_dive -- ./your_app",
                    code_experiments=[
                        "Check instruction mix and pipeline utilization before refactoring data movement.",
                        "Consider FMA-friendly rewrites or math-path changes only if they match the instruction mix.",
                    ],
                )
            )

        if eligible is not None and issued is not None and eligible < 1.0 and issued < 0.6:
            diagnoses.append(
                Diagnosis(
                    title="Possible latency-hiding or scheduler issue",
                    confidence="high",
                    evidence=[
                        f"Eligible warps per scheduler is {eligible:.2f}.",
                        f"Issued warps per scheduler is {issued:.2f}.",
                    ],
                    uncertainty=[
                        "Warp stall reasons should be interpreted only after confirming poor issue efficiency.",
                    ],
                    next_command=DEFAULT_NEXT_COMMANDS["scheduler"],
                    code_experiments=[
                        "Inspect dependency chains and memory latency sources before changing occupancy knobs.",
                        "Use source-correlated counters to locate the code region with poor issue efficiency.",
                    ],
                )
            )

        if not diagnoses:
            diagnoses.append(
                Diagnosis(
                    title="No dominant bottleneck identified from current metrics",
                    confidence="low",
                    evidence=["The available metrics do not point to one clear root cause."],
                    uncertainty=[
                        "The report may be too small for a deep diagnosis.",
                        "A focused section set may be required to answer the next question.",
                    ],
                    next_command=DEFAULT_NEXT_COMMANDS["memory"],
                    code_experiments=[
                        "Collect one deeper profile aimed at the suspected subsystem instead of jumping to code changes.",
                    ],
                )
            )

        return diagnoses

    def render_markdown(self, kernel_name: str, metrics: Dict[str, float], diagnoses: List[Diagnosis]) -> str:
        lines = [
            "# NCU Performance Analysis",
            "",
            "## Workload",
            f"- Kernel focus: `{kernel_name}`",
            f"- Report source: `{self.report_file}`" if self.report_file else "- Report source: `raw csv / summary import`",
            "",
            "## Executive Summary",
            f"- Primary hypothesis: {diagnoses[0].title}",
            f"- Confidence: {diagnoses[0].confidence}",
            "- Why this is the current best explanation: based on the strongest available high-level metrics, not a single-threshold claim.",
            "",
            "## Key Metrics",
        ]

        for key in (
            "sm_busy",
            "sm_throughput",
            "memory_throughput",
            "dram_throughput",
            "l1tex_throughput",
            "l2_throughput",
            "achieved_occupancy",
            "registers_per_thread",
            "eligible_warps_per_scheduler",
            "issued_warps_per_scheduler",
            "duration",
        ):
            if key in metrics:
                lines.append(f"- {METRIC_DISPLAY[key]}: {metrics[key]:.2f}")

        lines.extend(["", "## Diagnoses"])
        for diagnosis in diagnoses:
            lines.append(f"### {diagnosis.title} ({diagnosis.confidence})")
            lines.append("")
            lines.append("**Evidence**")
            for item in diagnosis.evidence:
                lines.append(f"- {item}")
            lines.append("")
            lines.append("**What this does not prove yet**")
            for item in diagnosis.uncertainty:
                lines.append(f"- {item}")
            lines.append("")
            lines.append("**Next command**")
            lines.append("```bash")
            lines.append(diagnosis.next_command)
            lines.append("```")
            lines.append("")
            lines.append("**Likely code-level experiments**")
            for item in diagnosis.code_experiments:
                lines.append(f"- {item}")
            lines.append("")

        return "\n".join(lines)

    def render_json(self, kernel_name: str, metrics: Dict[str, float], diagnoses: List[Diagnosis]) -> str:
        payload = {
            "kernel": kernel_name,
            "report_file": self.report_file,
            "metrics": metrics,
            "diagnoses": [
                {
                    "title": item.title,
                    "confidence": item.confidence,
                    "evidence": item.evidence,
                    "uncertainty": item.uncertainty,
                    "next_command": item.next_command,
                    "code_experiments": item.code_experiments,
                }
                for item in diagnoses
            ],
        }
        return json.dumps(payload, indent=2, ensure_ascii=False)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Analyze Nsight Compute reports with raw CSV first and summary text as fallback."
    )
    parser.add_argument("--import", dest="import_file", help="Import an existing .ncu-rep report.")
    parser.add_argument("--csv", help="Path to a raw CSV exported by ncu --page raw --csv.")
    parser.add_argument("--summary-file", help="Optional summary file from ncu --print-summary per-kernel.")
    parser.add_argument("--report-file", help="Optional report path shown in the output.")
    parser.add_argument("--kernel-name", help="Analyze a specific kernel by exact name.")
    parser.add_argument("--kernel-regex", help="Analyze the first kernel matching this regex.")
    parser.add_argument("-o", "--output", help="Write markdown analysis to this file.")
    parser.add_argument("--json", action="store_true", help="Print JSON instead of markdown.")
    args = parser.parse_args()

    if not args.import_file and not args.csv and not args.summary_file:
        parser.error("Provide --import or at least one of --csv / --summary-file.")

    analyzer = NCUAnalyzer(
        kernel_name=args.kernel_name,
        kernel_regex=args.kernel_regex,
        report_file=args.report_file or args.import_file,
    )
    analyzer.load(args.csv, args.summary_file, args.import_file)
    kernel_name, metrics, diagnoses = analyzer.analyze()

    output = analyzer.render_json(kernel_name, metrics, diagnoses) if args.json else analyzer.render_markdown(kernel_name, metrics, diagnoses)

    if args.output:
        Path(args.output).write_text(output, encoding="utf-8")
    else:
        print(output)


if __name__ == "__main__":
    main()
