#!/usr/bin/env bash
# swarm-launch.sh — opt-in launcher for the `swarm` skill (macOS + alacritty).
#
# Runs ONLY after the swarm doctor cost gate has been confirmed (`y`) and the
# manager has written the kickoff prompts + manifest. Opens one positioned
# alacritty window per front, each cd'd into its own pre-created git worktree,
# starting its worker autonomously via the user's `cc` function.
#
# Usage: swarm-launch.sh <repo-root>
#
# Reads <repo-root>/.swarm/launch.tsv  (TAB-separated, one row per front):
#   front \t branch \t promptfile [\t model] [\t effort]
# where promptfile is relative to <repo-root> (e.g. .swarm/prompts/<front>.md)
# or absolute. The optional 4th/5th columns set per-front `--model` / `--effort`.
# If a file .swarm/prompts/<front>.system.md exists it is passed as a per-front
# `--append-system-prompt` scope guard.

set -euo pipefail

die() { printf 'swarm-launch: %s\n' "$1" >&2; exit 1; }

REPO="${1:-}"
[ -n "$REPO" ] || die "usage: swarm-launch.sh <repo-root>"
[ -d "$REPO/.git" ] || git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || die "not a git repo: $REPO"
REPO="$(cd "$REPO" && pwd)"   # absolute

command -v alacritty >/dev/null 2>&1 || die "alacritty not found — use the emit-only path (hand the kickoff prompts to the human)."

MANIFEST="$REPO/.swarm/launch.tsv"
[ -f "$MANIFEST" ] || die "manifest missing: $MANIFEST (manager must write it before launch)."

# Read manifest rows (skip blanks / comments).
fronts=(); branches=(); prompts=(); models=(); efforts=()
while IFS=$'\t' read -r front branch prompt model effort _rest; do
  [ -z "${front:-}" ] && continue
  case "$front" in \#*) continue;; esac
  fronts+=("$front"); branches+=("$branch"); prompts+=("$prompt")
  models+=("${model:-}"); efforts+=("${effort:-}")
done < "$MANIFEST"

N="${#fronts[@]}"
# Defense-in-depth: mirror the skill's hard floor. The doctor gate already
# enforced this upstream; refuse here too so the launcher can never be run
# against a sub-floor swarm.
[ "$N" -ge 4 ] || die "only $N front(s) in manifest — below the swarm floor of 4. Refusing to launch."

# --- Pre-create all worktrees SERIALLY (concurrent `git worktree add` from N
#     windows would race on git's repo lock). -----------------------------------
WT_BASE="$REPO/.swarm/worktrees"
mkdir -p "$WT_BASE"
for i in "${!fronts[@]}"; do
  front="${fronts[$i]}"; branch="${branches[$i]}"
  wt="$WT_BASE/$front"
  if [ -d "$wt" ]; then
    printf 'swarm-launch: worktree exists, reusing: %s\n' "$wt"
    continue
  fi
  if git -C "$REPO" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$REPO" worktree add "$wt" "$branch"          # branch already exists
  else
    git -C "$REPO" worktree add "$wt" -b "$branch"        # create branch
  fi
done

# --- Compute the screen grid. -------------------------------------------------
# Logical screen size via Finder desktop bounds ("0, 0, W, H"); fallback 1440x900.
read -r SCR_W SCR_H < <(
  osascript -e 'tell application "Finder" to get bounds of window of desktop' 2>/dev/null \
    | awk -F', *' '{print $3, $4}'
) || true   # read returns non-zero on empty input; fall through to the default below
[ -n "${SCR_W:-}" ] && [ -n "${SCR_H:-}" ] || { SCR_W=1440; SCR_H=900; }
MENUBAR=25
USABLE_H=$(( SCR_H - MENUBAR ))

# alacritty's `window.position` is in PHYSICAL/device pixels, but the screen size
# above (and all macOS window coords) are LOGICAL points. On a Retina display the
# backing scale is 2.0 (even in a scaled resolution mode), so a logical position L
# must be passed to alacritty as L*SCALE. Verified empirically: requesting 1200,400
# lands a window at logical 600,200. Non-Retina displays are 1.0.
SCALE=1
system_profiler SPDisplaysDataType 2>/dev/null | grep -qi 'retina' && SCALE=2

# cols = ceil(sqrt(N)); rows = ceil(N/cols)
COLS=$(awk -v n="$N" 'BEGIN{ c=int(sqrt(n)); if (c*c<n) c++; print c }')
ROWS=$(awk -v n="$N" -v c="$COLS" 'BEGIN{ r=int(n/c); if (r*c<n) r++; print r }')
CELL_W=$(( SCR_W / COLS ))
CELL_H=$(( USABLE_H / ROWS ))

# Rough px→cell conversion for alacritty's column/line dimensions (cells are
# columns/lines, not pixels). Approximate monospace cell ~8px wide x 17px tall;
# clamp to sane minimums. Position is exact; size is best-effort.
CHAR_W=8; CHAR_H=17
COLUMNS_PER_CELL=$(( CELL_W / CHAR_W )); [ "$COLUMNS_PER_CELL" -lt 40 ] && COLUMNS_PER_CELL=40
LINES_PER_CELL=$(( CELL_H / CHAR_H ));   [ "$LINES_PER_CELL"   -lt 10 ] && LINES_PER_CELL=10

# --- Launch one positioned window per front. ----------------------------------
printf 'swarm-launch: %d fronts, %dx%d grid on %dx%d screen\n' "$N" "$COLS" "$ROWS" "$SCR_W" "$SCR_H"
for i in "${!fronts[@]}"; do
  front="${fronts[$i]}"; prompt="${prompts[$i]}"
  wt="$WT_BASE/$front"

  # Resolve prompt path (relative → repo-root).
  case "$prompt" in
    /*) pf="$prompt";;
    *)  pf="$REPO/$prompt";;
  esac
  [ -f "$pf" ] || die "prompt file missing for front '$front': $pf"

  col=$(( i % COLS )); row=$(( i / COLS ))
  # Grid is computed in logical points; alacritty wants physical pixels → ×SCALE.
  X=$(( col * CELL_W * SCALE )); Y=$(( (MENUBAR + row * CELL_H) * SCALE ))

  # Build the cc flags. ORDER MATTERS: `--add-dir` is variadic, so it must be
  # followed by another flag (here `-n`) — never directly by the positional
  # prompt, or it would swallow the prompt as a directory. `--append-system-prompt`
  # (one arg) is kept last so the positional prompt lands cleanly after it.
  #   --add-dir <.swarm>  → reach the shared blackboard, which sits ABOVE the
  #                         worktree cwd ($REPO/.swarm/worktrees/<front>).
  #   -n swarm-<front>    → session name in prompt box / /resume picker / title.
  #   --model / --effort  → optional per-front power/cost tuning (manifest cols).
  ccflags="--add-dir $(printf %q "$REPO/.swarm") -n $(printf %q "swarm-$front")"
  [ -n "${models[$i]}" ]  && ccflags="$ccflags --model $(printf %q "${models[$i]}")"
  [ -n "${efforts[$i]}" ] && ccflags="$ccflags --effort $(printf %q "${efforts[$i]}")"
  guard="$REPO/.swarm/prompts/$front.system.md"
  [ -f "$guard" ] && ccflags="$ccflags --append-system-prompt \"\$(cat $(printf %q "$guard"))\""

  # `cc` is an interactive zsh function → run via `zsh -ic`. The prompt (and the
  # optional guard) are read from files at runtime (\$(cat …) kept literal here,
  # expanded by inner zsh) to avoid quoting large multi-line text on the cmdline.
  inner="cd $(printf %q "$wt"); cc $ccflags \"\$(cat $(printf %q "$pf"))\""

  printf 'swarm-launch: window swarm:%s at (%d,%d) → %s\n' "$front" "$X" "$Y" "$wt"
  nohup alacritty \
    -T "swarm:$front" \
    -o "window.position.x=$X" \
    -o "window.position.y=$Y" \
    -o "window.dimensions.columns=$COLUMNS_PER_CELL" \
    -o "window.dimensions.lines=$LINES_PER_CELL" \
    -e zsh -ic "$inner" >/dev/null 2>&1 &
  disown 2>/dev/null || true
  sleep 0.3   # let the window manager place each before the next
done

cat <<EOF
swarm-launch: launched $N autonomous workers (titled "swarm:<front>").
  These run \`cc\` = claude --dangerously-skip-permissions and start immediately.
  Watch the running cost; close idle windows. Teardown: scripts/swarm-down.sh "$REPO"
EOF
