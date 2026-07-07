#!/usr/bin/env bash
# Detect code that executes on clone / checkout / editor-open / container-build —
# i.e. BEFORE you ever explicitly run the project. These are the vectors that turn
# "I just cloned/opened it to look" into arbitrary code execution.
set -uo pipefail

TARGET="${1:-.}"

echo ""
echo "=== SCAN 08: Auto-Execution Vectors ==="

FOUND=0

flag() {
  local sev="$1" file="$2" detail="$3"
  echo "[$sev] $file"
  echo "  $detail"
  FOUND=1
}

# ── Git hooks (run on git operations) ──────────────────────────────────────────
HOOKS_DIR="$TARGET/.git/hooks"
if [[ -d "$HOOKS_DIR" ]]; then
  echo "[INFO] Checking .git/hooks for active (non-sample) hooks..."
  # Glob (not find -print0/read -d '') — git hook names are fixed & space-free, and
  # the NUL-read idiom silently returns nothing under macOS system bash 3.2.
  for hook in "$HOOKS_DIR"/*; do
    [[ -f "$hook" && -x "$hook" ]] || continue
    base=$(basename "$hook")
    [[ "$base" == *.sample ]] && continue
    flag "HIGH" ".git/hooks/$base" "Active git hook — executes on git operations (clone/commit/checkout):"
    head -8 "$hook" 2>/dev/null | sed 's/^/    /'
  done
fi

# Also flag a repo-configured hooksPath (redirects hooks into tracked, runnable dir).
if [[ -f "$TARGET/.git/config" ]] && grep -qE '^\s*hooksPath' "$TARGET/.git/config" 2>/dev/null; then
  flag "HIGH" ".git/config" "core.hooksPath override — hooks may live in a tracked repo dir:"
  grep -nE 'hooksPath' "$TARGET/.git/config" | sed 's/^/    /'
fi

# ── direnv (.envrc runs automatically on cd into the dir) ───────────────────────
if [[ -f "$TARGET/.envrc" ]]; then
  flag "HIGH" ".envrc" "direnv auto-executes this on 'cd' into the repo (if direnv is installed & allowed):"
  head -15 "$TARGET/.envrc" 2>/dev/null | sed 's/^/    /'
fi

# ── VS Code tasks that auto-run on folder open ─────────────────────────────────
VSC_TASKS="$TARGET/.vscode/tasks.json"
if [[ -f "$VSC_TASKS" ]]; then
  echo "[INFO] Checking .vscode/tasks.json for folderOpen auto-run..."
  python3 - "$VSC_TASKS" <<'EOF' 2>/dev/null || true
import json, sys, re
raw = open(sys.argv[1]).read()
# Tolerate // comments and trailing commas (VS Code JSONC).
raw = re.sub(r'//[^\n]*', '', raw)
raw = re.sub(r',(\s*[}\]])', r'\1', raw)
try:
    d = json.loads(raw)
except Exception:
    sys.exit(0)
for t in d.get('tasks', []):
    ro = t.get('runOptions', {})
    if ro.get('runOn') == 'folderOpen':
        label = t.get('label', '?')
        cmd = t.get('command', '')
        args = ' '.join(t.get('args', []) if isinstance(t.get('args'), list) else [])
        print(f"[HIGH] .vscode/tasks.json")
        print(f"  Task '{label}' runs automatically on folder open: {cmd} {args}".rstrip())
EOF
  grep -q "folderOpen" "$VSC_TASKS" 2>/dev/null && FOUND=1
fi

# ── VS Code settings that redirect executables / inject env ────────────────────
VSC_SETTINGS="$TARGET/.vscode/settings.json"
if [[ -f "$VSC_SETTINGS" ]]; then
  if grep -qE 'terminal\.integrated\.env|\.interpreterPath|\.exePath|executablePath|"git\.path"|\.defaultInterpreterPath' "$VSC_SETTINGS" 2>/dev/null; then
    flag "MEDIUM" ".vscode/settings.json" "Overrides an executable path or injects terminal env (can run repo-local binaries):"
    grep -nE 'terminal\.integrated\.env|interpreterPath|exePath|executablePath|"git\.path"' "$VSC_SETTINGS" | head -8 | sed 's/^/    /'
  fi
fi

# ── Dev containers (commands run on container create/build) ────────────────────
while IFS= read -r dc; do
  [[ -z "$dc" ]] && continue
  fname="${dc#$TARGET/}"
  matches=$(grep -nE '"(postCreateCommand|onCreateCommand|initializeCommand|updateContentCommand|postStartCommand)"' "$dc" 2>/dev/null || true)
  [[ -z "$matches" ]] && continue
  # Escalate if the command fetches from the network or pipes to a shell.
  if echo "$matches" | grep -qiE 'curl|wget|http|\| *(sh|bash)'; then
    flag "HIGH" "$fname" "Dev-container lifecycle command with network/shell exec:"
  else
    flag "MEDIUM" "$fname" "Dev-container lifecycle command runs on container create:"
  fi
  echo "$matches" | head -6 | sed 's/^/    /'
done < <(find "$TARGET" -maxdepth 3 \( -name "devcontainer.json" -o -name ".devcontainer.json" \) -print 2>/dev/null)

[[ "$FOUND" -eq 0 ]] && echo "[INFO] No auto-execution vectors found."
exit 0
