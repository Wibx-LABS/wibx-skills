#!/bin/bash
# rtk — statusline badge for Claude Code.
# Shows [RTK <pct>% <saved>] when the rtk PreToolUse hook is wired and the
# binary exists. Savings come from `rtk gain -f json`, cached with a TTL so
# the statusline never blocks on rtk itself.

command -v rtk >/dev/null 2>&1 || exit 0

SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
grep -q "rtk hook" "$SETTINGS" 2>/dev/null || exit 0

CACHE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.rtk-statusline-cache"
TTL=300

# Refuse symlinks — same hardening as the caveman badge (a local attacker
# could point the cache at a file with ANSI escapes otherwise).
[ -L "$CACHE" ] && exit 0

# Refresh cache in background when stale/absent; render from the old value
# meanwhile so this script stays O(read one file).
STALE=1
if [ -f "$CACHE" ]; then
  NOW=$(date +%s)
  MTIME=$(stat -f %m "$CACHE" 2>/dev/null || stat -c %Y "$CACHE" 2>/dev/null || echo 0)
  [ $((NOW - MTIME)) -lt "$TTL" ] && STALE=0
fi
if [ "$STALE" = 1 ]; then
  (
    JSON=$(rtk gain --format json 2>/dev/null) || exit 0
    PCT=$(printf '%s' "$JSON" | sed -n 's/.*"avg_savings_pct": *\([0-9]*\)\..*/\1/p' | head -1)
    [ -n "$PCT" ] || exit 0
    printf '%s%%' "$PCT" > "$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"
  ) >/dev/null 2>&1 &
fi

# Render. Cap read + strip anything outside the tiny expected charset —
# blocks terminal-escape injection via the cache contents.
if [ -f "$CACHE" ]; then
  VAL=$(head -c 32 "$CACHE" 2>/dev/null | tr -cd '0-9.%')
  [ -n "$VAL" ] && printf '\033[38;5;39m[RTK %s]\033[0m' "$VAL" && exit 0
fi
# Cache not built yet — plain badge.
printf '\033[38;5;39m[RTK]\033[0m'
