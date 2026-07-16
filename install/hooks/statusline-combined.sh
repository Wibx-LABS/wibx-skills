#!/bin/bash
# Combined statusline for Claude Code — renders every badge script found in
# ~/.claude/hooks/*-statusline.sh side by side ([CAVEMAN] [PONYTAIL] [RTK …]).
# Each badge script exits silently when its mode flag / tool is absent, so
# missing pieces just don't render. Drop a new *-statusline.sh in the hooks
# dir and it's picked up automatically (sorted order = stable badge order).
#
# Wired by wibx-skills install.py as:
#   "statusLine": { "type": "command", "command": "bash ~/.claude/hooks/statusline-combined.sh" }

HOOKS_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks"
INPUT=$(cat)
OUT=""
for S in "$HOOKS_DIR"/*-statusline.sh; do
  [ -f "$S" ] || continue
  BADGE=$(printf '%s' "$INPUT" | bash "$S" 2>/dev/null)
  if [ -n "$BADGE" ]; then
    [ -n "$OUT" ] && OUT="$OUT $BADGE" || OUT="$BADGE"
  fi
done
printf '%s' "$OUT"
