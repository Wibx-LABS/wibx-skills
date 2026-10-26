#!/bin/bash
# Lança um subagente do Antigravity (agy) desacoplado, num diretório isolado.
# Sobrevive ao limite de tempo dos comandos em background do Claude Code (nohup).
#
# uso: agy-run.sh <dir-isolado> <arquivo-prompt> [modelo] [timeout-segundos]
#   modelo  padrão gemini-3.8-flash-high (lista: agy models)
#   timeout padrão 7200
# Saída: o caminho do diretório de execução. Lá ficam:
#   log.json   saída JSON do agy (resultado final em .result, uso em .usage)
#   fim        aparece quando termina: "rc=<código> segundos=<n>"
#   pid        pid do processo
# Esperar o fim: until [ -f <run>/fim ]; do sleep 30; done
set -euo pipefail
DIR=$(cd "${1:?dir isolado}" && pwd)
PROMPT=$(cd "$(dirname "${2:?arquivo de prompt}")" && pwd)/$(basename "$2")
MODEL=${3:-gemini-3.8-flash-high}
TO=${4:-7200}
command -v agy >/dev/null || { echo "agy não encontrado no PATH" >&2; exit 2; }
git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1 || { echo "$DIR não é um repo git (use um clone ou worktree isolado)" >&2; exit 2; }
RUN=$(mktemp -d "${TMPDIR:-/tmp}/agy-run.XXXXXX")
cd "$DIR"
nohup bash -c '
  start=$(date +%s)
  timeout "$0" agy -p "$(cat "$1")" --model "$2" --effort high --sandbox \
    --dangerously-skip-permissions --output-format json >"$3/log.json" 2>&1
  rc=$?
  echo "rc=$rc segundos=$(( $(date +%s) - start ))" >"$3/fim"
' "$TO" "$PROMPT" "$MODEL" "$RUN" >/dev/null 2>&1 &
echo $! >"$RUN/pid"
echo "$RUN"
