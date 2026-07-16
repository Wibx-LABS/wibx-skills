#!/bin/bash
# graphify — statusline badge for Claude Code.
# Lights up [GRAPHIFY] when the session's cwd has a knowledge graph
# (graphify-out/graph.json). Per-project artifact, so this reads the cwd
# from the statusline stdin JSON rather than any global flag.

INPUT=$(cat)
# workspace.current_dir first, top-level cwd as fallback, $PWD as last resort.
DIR=$(printf '%s' "$INPUT" | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -n "$DIR" ] || DIR=$(printf '%s' "$INPUT" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -n "$DIR" ] || DIR=$PWD

[ -f "$DIR/graphify-out/graph.json" ] || exit 0
printf '\033[38;5;135m[GRAPHIFY]\033[0m'
