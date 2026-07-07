#!/usr/bin/env bash
# Detect committed secrets, leaked credentials, and tracked .env files in a repo.
# Runs gitleaks when available (working tree + full git history) and always runs a
# regex fallback so coverage never depends on an optional tool being installed.
set -uo pipefail

TARGET="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS="$SCRIPT_DIR/patterns/secrets.txt"

echo ""
echo "=== SCAN 07: Secrets & Credentials ==="

FOUND=0
# Slash-anchored so it only drops directory segments — NOT files like .env / .envrc.
EXCLUDE_DIRS="/(node_modules|\.git|vendor|dist|build|\.next|__pycache__|\.venv|venv|\.terraform)/"

# ── gitleaks: working tree + full history ──────────────────────────────────────
if command -v gitleaks &>/dev/null; then
  # Working tree (uncommitted + current files), independent of git state.
  echo "[INFO] Running gitleaks on working tree..."
  GL_OUT=$(gitleaks dir "$TARGET" --no-banner --redact 2>/dev/null || true)
  if echo "$GL_OUT" | grep -qiE "finding|secret|leak"; then
    LEAK_N=$(echo "$GL_OUT" | grep -ciE "Finding:" || echo "?")
    echo "[CRITICAL] gitleaks flagged $LEAK_N secret(s) in the working tree:"
    echo "$GL_OUT" | grep -iE "Finding:|File:|Secret:|RuleID:|Line:" | head -40 | sed 's/^/  /'
    FOUND=1
  fi

  # Full git history (secrets committed then deleted still live in history).
  if [[ -d "$TARGET/.git" ]]; then
    echo "[INFO] Running gitleaks over full git history..."
    GLH_OUT=$(git -C "$TARGET" rev-parse --is-inside-work-tree &>/dev/null \
      && gitleaks detect --source "$TARGET" --no-banner --redact 2>/dev/null || true)
    if echo "$GLH_OUT" | grep -qiE "Finding:"; then
      LEAKH_N=$(echo "$GLH_OUT" | grep -ciE "Finding:" || echo "?")
      echo "[CRITICAL] gitleaks flagged $LEAKH_N secret(s) in git history:"
      echo "$GLH_OUT" | grep -iE "Finding:|File:|Secret:|RuleID:|Commit:|Date:" | head -40 | sed 's/^/  /'
      FOUND=1
    fi
  fi
else
  echo "[INFO] gitleaks not installed — using regex fallback only (install: brew install gitleaks)"
fi

# ── Regex fallback (always runs) ───────────────────────────────────────────────
if [[ -f "$PATTERNS" ]]; then
  echo "[INFO] Scanning source for hardcoded secret patterns..."
  while IFS= read -r pattern; do
    [[ "$pattern" =~ ^# ]] && continue
    [[ -z "$pattern" ]] && continue
    matches=$(grep -rnI -E -e "$pattern" "$TARGET" 2>/dev/null \
              | grep -vE "$EXCLUDE_DIRS" \
              | grep -viE "example|sample|placeholder|dummy|your[_-]?(key|token|secret)|xxxx|<[a-z_]+>" \
              | head -8 || true)
    if [[ -n "$matches" ]]; then
      echo "[HIGH] Secret pattern matched: $pattern"
      echo "$matches" | sed -E 's/(['"'"'"][^'"'"'"]{4})[^'"'"'"]*(['"'"'"])/\1***\2/g; s/^/  /'
      FOUND=1
    fi
  done < "$PATTERNS"
fi

# ── git-tracked .env files (committed secrets) ─────────────────────────────────
if git -C "$TARGET" rev-parse --is-inside-work-tree &>/dev/null; then
  echo "[INFO] Checking for git-tracked .env files..."
  TRACKED_ENV=$(git -C "$TARGET" ls-files 2>/dev/null \
    | grep -E '(^|/)\.env(\.|$)' \
    | grep -vE '\.(example|sample|template|dist)$' || true)
  if [[ -n "$TRACKED_ENV" ]]; then
    echo "[HIGH] .env file(s) committed to git (should be gitignored):"
    echo "$TRACKED_ENV" | sed 's/^/  /'
    FOUND=1
  fi
else
  # Not a git repo — just note presence of .env with real content.
  while IFS= read -r ef; do
    echo "[INFO] .env file present (not in a git repo): ${ef#$TARGET/}"
  done < <(find "$TARGET" -maxdepth 2 -name ".env" ! -name "*.example" ! -name "*.sample" 2>/dev/null)
fi

# ── Inline credentials in rc/config files ──────────────────────────────────────
for rc in "$TARGET/.npmrc" "$TARGET/.pypirc" "$TARGET/.netrc"; do
  [[ -f "$rc" ]] || continue
  if grep -qiE '_authToken=|_password=|^\s*password|api_?key' "$rc" 2>/dev/null; then
    echo "[HIGH] Inline credential in ${rc#$TARGET/}:"
    grep -niE '_authToken=|_password=|^\s*password|api_?key' "$rc" \
      | sed -E 's/(=|:)\s*\S{4}\S*/\1 ****/; s/^/  /'
    FOUND=1
  fi
done

[[ "$FOUND" -eq 0 ]] && echo "[INFO] No secrets or committed credentials found."
exit 0
