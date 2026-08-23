#!/usr/bin/env zsh

set -eu

source "${0:A:h}/function.zsh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/completions" "$tmpdir/targets"
: > "$tmpdir/targets/_valid"
ln -s "$tmpdir/targets/_valid" "$tmpdir/completions/_valid"
ln -s "$tmpdir/targets/_missing" "$tmpdir/completions/_missing"
print -r -- stale > "$tmpdir/.zcompdump"

fpath=("$tmpdir/completions")
ZSH_COMPDUMP="$tmpdir/.zcompdump"
zsh_fix_completions

[[ -L "$tmpdir/completions/_valid" ]]
[[ ! -e "$tmpdir/completions/_missing" ]]
[[ ! -L "$tmpdir/completions/_missing" ]]
[[ ! -e "$tmpdir/.zcompdump" ]]

print -r -- fresh > "$tmpdir/.zcompdump"
zsh_fix_completions
[[ -e "$tmpdir/.zcompdump" ]]
