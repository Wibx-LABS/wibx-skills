#!/usr/bin/env bash
# swarm-down.sh — optional teardown for a launched swarm (macOS + alacritty).
#
# Lists the swarm worktrees, removes the ones whose branch is already merged into
# the default branch and whose tree is clean, and offers to close the leftover
# "swarm:<front>" windows.
#
# Usage:
#   swarm-down.sh <repo-root>            # remove merged+clean worktrees, report the rest
#   swarm-down.sh <repo-root> --windows  # also kill the swarm:* alacritty windows
#   swarm-down.sh <repo-root> --all      # remove ALL swarm worktrees (force), even unmerged

set -euo pipefail
die() { printf 'swarm-down: %s\n' "$1" >&2; exit 1; }

REPO="${1:-}"
[ -n "$REPO" ] || die "usage: swarm-down.sh <repo-root> [--windows] [--all]"
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || die "not a git repo: $REPO"
REPO="$(cd "$REPO" && pwd)"
shift || true
KILL_WINDOWS=0; FORCE_ALL=0
for arg in "$@"; do
  case "$arg" in
    --windows) KILL_WINDOWS=1;;
    --all)     FORCE_ALL=1;;
    *) die "unknown flag: $arg";;
  esac
done

WT_BASE="$REPO/.swarm/worktrees"
DEFAULT_BRANCH="$(git -C "$REPO" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@' || true)"
[ -n "$DEFAULT_BRANCH" ] || DEFAULT_BRANCH="$(git -C "$REPO" rev-parse --abbrev-ref HEAD)"

if [ ! -d "$WT_BASE" ]; then
  printf 'swarm-down: no worktrees under %s — nothing to remove.\n' "$WT_BASE"
else
  merged="$(git -C "$REPO" branch --merged "$DEFAULT_BRANCH" --format='%(refname:short)' 2>/dev/null || true)"
  for wt in "$WT_BASE"/*/; do
    [ -d "$wt" ] || continue
    wt="${wt%/}"; front="$(basename "$wt")"
    branch="$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
    dirty=""; git -C "$wt" diff --quiet --ignore-submodules 2>/dev/null && git -C "$wt" diff --cached --quiet 2>/dev/null || dirty="dirty"
    is_merged=0; grep -qxF "$branch" <<<"$merged" && is_merged=1

    if [ "$FORCE_ALL" -eq 1 ]; then
      printf 'swarm-down: force-removing %s (branch %s)\n' "$front" "$branch"
      git -C "$REPO" worktree remove --force "$wt"
    elif [ "$is_merged" -eq 1 ] && [ -z "$dirty" ]; then
      printf 'swarm-down: removing merged+clean %s (branch %s)\n' "$front" "$branch"
      git -C "$REPO" worktree remove "$wt"
    else
      printf 'swarm-down: KEEPING %s (branch %s%s%s) — not merged or dirty; remove by hand or rerun with --all\n' \
        "$front" "$branch" "$([ "$is_merged" -eq 1 ] && echo ', merged' || echo ', unmerged')" "$([ -n "$dirty" ] && echo ', dirty' || echo '')"
    fi
  done
  git -C "$REPO" worktree prune
fi

if [ "$KILL_WINDOWS" -eq 1 ]; then
  # alacritty windows carry "-T swarm:<front>" in their argv.
  if pkill -f 'alacritty.*swarm:' 2>/dev/null; then
    printf 'swarm-down: closed swarm:* alacritty windows.\n'
  else
    printf 'swarm-down: no swarm:* windows running.\n'
  fi
else
  printf 'swarm-down: leftover windows (if any) titled "swarm:<front>" — close them, or rerun with --windows.\n'
fi
