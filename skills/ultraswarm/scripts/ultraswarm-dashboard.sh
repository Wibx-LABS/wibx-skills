#!/usr/bin/env bash
# ultraswarm-dashboard.sh — read-only live dashboard for an ultraswarm run.
#
# Pure observer: it ONLY reads .swarm/ files, session transcripts, and `rtk gain`.
# It never writes to the blackboard, the repo, or anything else. Safe to open in a
# spare terminal alongside a running swarm.
#
# Usage: ultraswarm-dashboard.sh <repo-root> [refresh-seconds]
#
# Panels (refreshed on a poll, default every 2s):
#   1. Fronts       — the blackboard table (front · status · goal_met · reviewed · …)
#   2. Event feed   — the tail of .swarm/log.md
#   3. Tokens       — per-front + total tokens USED (from each swarm-<front> session
#                     transcript) and estimated tokens SAVED (from `rtk gain`)
#   4. Cost         — running-instance reminder + count of not-yet-done fronts
#
# Honesty: token-USED needs the local session transcripts under ~/.claude/projects;
# if none are found for a front it shows "n/a". Token-SAVED is a cumulative,
# heuristic estimate from RTK — not an exact per-run figure. No local shell / no
# transcripts ⇒ the token panel degrades to "unavailable" and the blackboard + log
# panels still work.

set -uo pipefail

REPO="${1:-}"
REFRESH="${2:-2}"
[ -n "$REPO" ] || { printf 'usage: ultraswarm-dashboard.sh <repo-root> [refresh-seconds]\n' >&2; exit 1; }
[ -d "$REPO/.swarm" ] || { printf 'ultraswarm-dashboard: no .swarm/ under %s — nothing to watch yet.\n' "$REPO" >&2; exit 1; }
REPO="$(cd "$REPO" && pwd)"
SWARM="$REPO/.swarm"
BOARD="$SWARM/blackboard.md"
LOG="$SWARM/log.md"
PROJECTS="$HOME/.claude/projects"

# --- UI setup: colours + no-flicker redraw, all gated on a real TTY so headless
#     captures stay plain. ---------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  TTY=1
  B=$'\033[1m'; DIM=$'\033[2m'; R=$'\033[0m'
  GRN=$'\033[32m'; YEL=$'\033[33m'; CYN=$'\033[36m'; RED=$'\033[31m'; GRY=$'\033[90m'
else
  TTY=0
  B=''; DIM=''; R=''; GRN=''; YEL=''; CYN=''; RED=''; GRY=''
fi

cleanup() {
  [ "$TTY" = 1 ] && printf '\033[?25h\033[?1049l'   # show cursor, leave alt-screen
  printf '[dashboard closed — nothing was modified]\n'
  exit 0
}
trap cleanup INT TERM
if [ "$TTY" = 1 ]; then
  printf '\033[?1049h\033[?25l'   # enter alt-screen, hide cursor
fi

# List front names from the blackboard table (first cell of each data row, skipping
# the header + separator rows and the "(unclaimed)"-style header words).
fronts() {
  [ -f "$BOARD" ] || return 0
  awk -F'|' '
    /^\|/ {
      gsub(/^[ \t]+|[ \t]+$/, "", $2)
      if ($2 == "" || $2 == "front" || $2 ~ /^-+$/) next
      print $2
    }' "$BOARD"
}

# Emit one TAB row per front: front, status, goal_met, reviewed, owner.
# Column layout: | front | owner | branch | owned_paths | status | goal_met | reviewed | blocked |
#                  $2      $3      $4       $5            $6       $7         $8         $9
# Older base-swarm boards lack goal_met/reviewed — those cells come out blank (rendered as —).
board_rows() {
  [ -f "$BOARD" ] || return 0
  awk -F'|' '
    /^\|/ {
      for (i=1;i<=NF;i++) gsub(/^[ \t]+|[ \t]+$/, "", $i)
      if ($2 == "" || $2 == "front" || $2 ~ /^-+$/) next
      printf "%s\t%s\t%s\t%s\t%s\n", $2, $6, $7, $8, $3
    }' "$BOARD"
}

# Candidate transcripts: files that mention ANY "swarm-" session name, found in ONE
# scan per render (populated by render()). Per-front lookup then searches only this
# short list instead of re-scanning all of ~/.claude/projects N times.
CANDIDATES=""
scan_candidates() {
  CANDIDATES=""
  [ -d "$PROJECTS" ] || return 0
  # Only recent transcripts (a live swarm's are fresh) — scanning the whole history
  # every 2s would stall the dashboard. Cap the file set too, for pathological dirs.
  CANDIDATES="$(find "$PROJECTS" -name '*.jsonl' -mtime -2 -print0 2>/dev/null \
    | xargs -0 grep -l -- 'swarm-' 2>/dev/null | head -n 200 || true)"
}

# Sum input+output tokens from a session transcript JSONL. Locates the transcript by
# matching the session name string "swarm-<front>" within the candidate list.
# Prints an integer, or "n/a" if no transcript is found / python3 is missing.
tokens_for_front() {
  local front="$1" name="swarm-$1" file
  command -v python3 >/dev/null 2>&1 || { printf 'n/a'; return; }
  [ -n "$CANDIDATES" ] || { printf 'n/a'; return; }
  file="$(printf '%s\n' "$CANDIDATES" | while IFS= read -r c; do
            [ -n "$c" ] && grep -lq -- "$name" "$c" 2>/dev/null && { printf '%s' "$c"; break; }
          done)"
  [ -n "$file" ] || { printf 'n/a'; return; }
  python3 - "$file" <<'PY' 2>/dev/null || printf 'n/a'
import json, sys
tot = 0
try:
    with open(sys.argv[1], encoding="utf-8", errors="ignore") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except Exception:
                continue
            u = (obj.get("message") or {}).get("usage") or obj.get("usage") or {}
            for k in ("input_tokens", "output_tokens",
                      "cache_read_input_tokens", "cache_creation_input_tokens"):
                v = u.get(k)
                if isinstance(v, int):
                    tot += v
    print(tot)
except Exception:
    print("n/a")
PY
}

fmt_int() { # 12345 -> 12,345 ; passes through non-numbers (e.g. "n/a")
  case "$1" in
    ''|*[!0-9]*) printf '%s' "$1" ;;
    *) printf "%s" "$1" | sed -e ':a' -e 's/\B[0-9]\{3\}\>/,&/;ta' ;;
  esac
}

# A section header: bold title + a dim rule filling the width.
hdr() { printf '%s%s%s %s%s%s\n' "$B" "$1" "$R" "$DIM" "${2:-────────────────────────────────────────}" "$R"; }

# Map a status word to a coloured glyph + padded label.
status_cell() {
  local s="$1" g c
  case "$s" in
    done)        g='✓'; c="$GRN" ;;
    blocked)     g='✗'; c="$RED" ;;
    in_progress) g='▶'; c="$CYN" ;;
    review)      g='◎'; c="$YEL" ;;
    claimed)     g='◐'; c="$GRY" ;;
    todo|*)      g='·'; c="$GRY"; s="${s:-todo}" ;;
  esac
  printf '%s%s %-11s%s' "$c" "$g" "$s" "$R"
}

# Build the whole frame into BUF, then paint it in one shot (no clear = no flicker).
render() {
  local now nf=0 ndone=0
  now="$(date '+%H:%M:%S' 2>/dev/null || echo '--:--:--')"
  BUF=""
  add() { BUF+="$1"$'\n'; }

  add "$(printf '%sULTRASWARM%s %s· %s ·%s %s%s%s' "$B" "$R" "$DIM" "$now" "$R" "$GRY" "$REPO" "$R")"
  add "$(printf '%sread-only observer — modifies nothing · ctrl-c to close · refresh %ss%s' "$DIM" "$REFRESH" "$R")"
  add ""

  # 1. Fronts -----------------------------------------------------------------
  add "$(hdr FRONTS)"
  if [ -f "$BOARD" ]; then
    add "$(printf '%s  %-18s %-13s %-4s %-9s %s%s' "$DIM" "FRONT" "STATUS" "GOAL" "REVIEW" "OWNER" "$R")"
    while IFS=$'\t' read -r front status goal rev owner; do
      [ -n "$front" ] || continue
      nf=$((nf+1)); [ "$status" = done ] && ndone=$((ndone+1))
      local gcell rcell
      case "$goal" in yes) gcell="${GRN}✓${R}  " ;; *) gcell="${GRY}·${R}  " ;; esac
      case "$rev" in
        clean)    rcell="${GRN}clean${R}   " ;;
        findings) rcell="${YEL}findings${R}" ;;
        *)        rcell="${GRY}—${R}       " ;;
      esac
      add "$(printf '  %-18s %s %s %s %s' "$front" "$(status_cell "$status")" "$gcell" "$rcell" "${GRY}${owner}${R}")"
    done < <(board_rows)
    [ "$nf" -eq 0 ] && add "  (no fronts yet)"
  else
    add "  (no blackboard.md yet)"
  fi
  add ""

  # 2. Events -----------------------------------------------------------------
  add "$(hdr EVENTS)"
  if [ -f "$LOG" ]; then
    local line
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      # dim the timestamp, keep the rest normal for scannability
      add "$(printf '  %s%s%s' "$GRY" "$line" "$R")"
    done < <(tail -n 10 "$LOG" 2>/dev/null)
  else
    add "  (no log.md yet)"
  fi
  add ""

  # 3. Tokens -----------------------------------------------------------------
  add "$(hdr TOKENS)"
  scan_candidates
  local total=0 any=0 f used
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    used="$(tokens_for_front "$f")"
    case "$used" in
      ''|*[!0-9]*) add "$(printf '  %-18s %s%8s%s' "$f" "$GRY" "n/a" "$R")" ;;
      *) total=$((total+used)); any=1
         add "$(printf '  %-18s %8s' "$f" "$(fmt_int "$used")")" ;;
    esac
  done < <(fronts)
  if [ "$any" -eq 1 ]; then
    add "$(printf '  %s%-18s %8s%s' "$B" "total used" "$(fmt_int "$total")" "$R")"
  else
    add "$(printf '  %s(no local session transcripts — token-used unavailable)%s' "$GRY" "$R")"
  fi
  if command -v rtk >/dev/null 2>&1; then
    local saved
    saved="$(rtk gain 2>/dev/null | grep -Ei 'saved' | head -n1 | sed 's/^[[:space:]]*//')"
    [ -n "$saved" ] && add "$(printf '  %ssaved  %s%s' "$GRN" "$saved" "$R")" \
                     || add "$(printf '  %ssaved  (rtk gain: no data)%s' "$GRY" "$R")"
  else
    add "$(printf '  %ssaved  n/a (rtk not on PATH)%s' "$GRY" "$R")"
  fi
  add ""

  # 4. Cost -------------------------------------------------------------------
  add "$(hdr COST)"
  add "$(printf '  %s%s%s instances running ≈ %s× a session + goal-loops + ultrareview  %s⚠%s   done %s%s/%s%s' \
    "$B" "$nf" "$R" "$nf" "$YEL" "$R" "$B" "$ndone" "$nf" "$R")"

  # Paint --------------------------------------------------------------------
  if [ "$TTY" = 1 ]; then
    printf '\033[H'                       # home, no clear
    printf '%s' "$BUF" | while IFS= read -r l; do printf '%s\033[K\n' "$l"; done
    printf '\033[J'                       # clear anything below the frame
  else
    printf '%s' "$BUF"
  fi
}

while :; do
  render
  sleep "$REFRESH" 2>/dev/null || sleep 2
done
