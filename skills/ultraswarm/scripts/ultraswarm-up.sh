#!/usr/bin/env bash
# ultraswarm-up.sh — opt-in launcher for the `ultraswarm` skill (macOS + alacritty).
#
# Thin wrapper over the base swarm launcher: it opens ONE extra read-only
# `ultraswarm:dashboard` window, then delegates to swarm/scripts/swarm-launch.sh
# to open the per-front worker windows (which pre-creates worktrees serially and
# starts each worker). Runs ONLY after the ultraswarm doctor cost gate `y`.
#
# Usage: ultraswarm-up.sh <repo-root>
#
# Reads the same manifest as swarm-launch.sh: <repo-root>/.swarm/launch.tsv
#   front \t branch \t promptfile [\t model] [\t effort]
# The model/effort columns come from the ultraswarm model-fit routing step.

set -euo pipefail

die() { printf 'ultraswarm-up: %s\n' "$1" >&2; exit 1; }

REPO="${1:-}"
[ -n "$REPO" ] || die "usage: ultraswarm-up.sh <repo-root>"
[ -d "$REPO/.git" ] || git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || die "not a git repo: $REPO"
REPO="$(cd "$REPO" && pwd)"

command -v alacritty >/dev/null 2>&1 || die "alacritty not found — use the emit-only path and run ultraswarm-dashboard.sh in a spare terminal."

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASH="$HERE/ultraswarm-dashboard.sh"
# swarm-launch.sh lives in the sibling swarm skill: skills/swarm/scripts/
LAUNCH="$(cd "$HERE/../../swarm/scripts" 2>/dev/null && pwd)/swarm-launch.sh"
[ -f "$DASH" ]   || die "dashboard script missing: $DASH"
[ -f "$LAUNCH" ] || die "base swarm launcher missing: $LAUNCH (ultraswarm reuses it)."

# --- Open the read-only dashboard window (top-left, wide). --------------------
printf 'ultraswarm-up: opening dashboard window (ultraswarm:dashboard)\n'
nohup alacritty \
  -T "ultraswarm:dashboard" \
  -o "window.position.x=0" \
  -o "window.position.y=0" \
  -o "window.dimensions.columns=100" \
  -o "window.dimensions.lines=28" \
  -e bash "$DASH" "$REPO" >/dev/null 2>&1 &
disown 2>/dev/null || true
sleep 0.5

# --- Delegate to the base swarm launcher for the front windows. ---------------
printf 'ultraswarm-up: delegating front launch to swarm-launch.sh\n'
exec bash "$LAUNCH" "$REPO"
