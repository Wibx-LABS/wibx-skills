#!/usr/bin/env bash
# Grep source files for obfuscation, exfiltration, and reverse shell patterns.
set -uo pipefail

TARGET="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS_DIR="$SCRIPT_DIR/patterns"

echo ""
echo "=== SCAN 03: Code Patterns ==="

FOUND=0
EXCLUDE_DIRS="node_modules|\.git|vendor|dist|build|\.next|__pycache__|\.venv|venv|env"

grep_patterns() {
  local label="$1"
  local sev="$2"
  local pattern_file="$3"

  [[ -f "$pattern_file" ]] || return

  while IFS= read -r pattern; do
    [[ "$pattern" =~ ^# ]] && continue
    [[ -z "$pattern" ]] && continue

    matches=$(grep -rn --include="*.js" --include="*.ts" --include="*.mjs" \
                       --include="*.py" --include="*.rb" --include="*.php" \
                       --include="*.go" --include="*.sh" --include="*.bash" \
                       -E "$pattern" "$TARGET" 2>/dev/null \
              | grep -vE "$EXCLUDE_DIRS" \
              | head -10 || true)

    if [[ -n "$matches" ]]; then
      echo "[$sev] [$label] Pattern: $pattern"
      echo "$matches" | sed 's/^/  /'
      echo ""
      FOUND=1
    fi
  done < "$pattern_file"
}

# ── Run pattern categories ─────────────────────────────────────────────────────
grep_patterns "OBFUSCATION"   "HIGH"     "$PATTERNS_DIR/obfuscation.txt"
grep_patterns "EXFILTRATION"  "CRITICAL" "$PATTERNS_DIR/exfil.txt"
grep_patterns "REVERSE-SHELL" "CRITICAL" "$PATTERNS_DIR/reverse-shells.txt"

# ── Long single-line string heuristic (obfuscated payloads) ───────────────────
echo "[INFO] Checking for suspiciously long single-line strings..."
find "$TARGET" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" \) \
  | grep -vE "$EXCLUDE_DIRS" \
  | while IFS= read -r f; do
      awk 'length($0) > 500 && /["'"'"'`]/ {
        printf "[HIGH] Long encoded string in %s:%d (%d chars)\n", FILENAME, NR, length($0)
      }' FILENAME="$f" "$f" 2>/dev/null || true
    done \
  | head -20

# ── Dynamic require/import patterns ───────────────────────────────────────────
echo "[INFO] Checking for dynamic require/import with user-controlled input..."
matches=$(grep -rn --include="*.js" --include="*.ts" \
  -E "require\s*\(\s*[a-zA-Z_\$][a-zA-Z0-9_\$]*\s*\)" "$TARGET" 2>/dev/null \
  | grep -vE "$EXCLUDE_DIRS" | grep -v "require(path\|require(file\|require(mod" \
  | head -10 || true)
if [[ -n "$matches" ]]; then
  echo "[MEDIUM] Dynamic require() with variable (possible code injection):"
  echo "$matches" | sed 's/^/  /'
  FOUND=1
fi

# ── Python exec/eval with non-literal args ─────────────────────────────────────
matches=$(grep -rn --include="*.py" \
  -E "^[^#]*(exec|eval)\s*\([^\"']{5,}" "$TARGET" 2>/dev/null \
  | grep -vE "$EXCLUDE_DIRS" | head -10 || true)
if [[ -n "$matches" ]]; then
  echo "[HIGH] Python exec/eval with non-literal argument:"
  echo "$matches" | sed 's/^/  /'
  FOUND=1
fi

[[ "$FOUND" -eq 0 ]] && echo "[INFO] No suspicious code patterns found."
exit 0
