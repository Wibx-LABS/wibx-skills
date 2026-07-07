#!/usr/bin/env bash
# Analyze build/install scripts for dangerous patterns that execute on install.
set -uo pipefail

TARGET="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS="$SCRIPT_DIR/patterns/build-risks.txt"

echo ""
echo "=== SCAN 02: Build Scripts ==="

FOUND=0

flag() {
  local sev="$1" file="$2" detail="$3"
  echo "[$sev] $file"
  echo "  $detail"
  FOUND=1
}

# ── package.json lifecycle scripts ─────────────────────────────────────────────
if [[ -f "$TARGET/package.json" ]]; then
  echo "[INFO] Checking package.json lifecycle scripts..."
  HOOKS=(preinstall postinstall install prepare prepublish prepack)
  for hook in "${HOOKS[@]}"; do
    val=$(python3 -c "
import json, sys
try:
    d = json.load(open('$TARGET/package.json'))
    s = d.get('scripts', {}).get('$hook', '')
    print(s)
except: pass
" 2>/dev/null || true)
    [[ -z "$val" ]] && continue

    # Always surface install-time hooks
    echo "[INFO] package.json scripts.$hook: $val"

    # Pattern match
    if echo "$val" | grep -qEi 'curl|wget|fetch|http|node -e|eval|base64'; then
      flag "CRITICAL" "package.json → scripts.$hook" "Network/eval in install hook: $val"
    elif echo "$val" | grep -qEi 'sh |bash |node '; then
      flag "HIGH" "package.json → scripts.$hook" "Shell execution in install hook: $val"
    fi
  done
fi

# ── Shell scripts in root and one level deep ───────────────────────────────────
echo "[INFO] Scanning shell scripts for dangerous patterns..."
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  # Skip node_modules, .git, dist, build
  [[ "$f" =~ node_modules|\.git/|dist/|build/ ]] && continue

  if [[ -f "$PATTERNS" ]]; then
    while IFS= read -r pattern; do
      [[ "$pattern" =~ ^# ]] && continue
      [[ -z "$pattern" ]] && continue
      matches=$(grep -nEi "$pattern" "$f" 2>/dev/null || true)
      if [[ -n "$matches" ]]; then
        flag "HIGH" "$f" "Pattern '$pattern' matched:"
        echo "$matches" | head -5 | sed 's/^/    /'
      fi
    done < "$PATTERNS"
  fi
done < <(find "$TARGET" -maxdepth 2 -name "*.sh" -print 2>/dev/null)

# ── Makefile ───────────────────────────────────────────────────────────────────
for mf in "$TARGET/Makefile" "$TARGET/makefile" "$TARGET/GNUmakefile"; do
  [[ -f "$mf" ]] || continue
  echo "[INFO] Checking $mf..."
  # Look for install/setup targets with network calls
  python3 - "$mf" <<'EOF'
import sys, re

content = open(sys.argv[1]).read()
targets = re.split(r'\n(?=\S)', content)
risky = ['install', 'setup', 'all', 'init', 'bootstrap', 'configure']
net_patterns = re.compile(r'curl|wget|http[s]?://|pip install|npm install', re.I)
eval_patterns = re.compile(r'eval|base64 -d|python -c|python3 -c', re.I)

for block in targets:
    lines = block.strip().split('\n')
    if not lines: continue
    target_name = lines[0].split(':')[0].strip().lower()
    if any(r in target_name for r in risky):
        body = '\n'.join(lines[1:])
        if net_patterns.search(body):
            print(f"[HIGH] Makefile target '{target_name}' contains network call:")
            for l in lines[1:]:
                if net_patterns.search(l):
                    print(f"  {l.strip()}")
        if eval_patterns.search(body):
            print(f"[HIGH] Makefile target '{target_name}' contains eval/inline exec:")
            for l in lines[1:]:
                if eval_patterns.search(l):
                    print(f"  {l.strip()}")
EOF
done

# ── setup.py / setup.cfg / pyproject.toml ──────────────────────────────────────
for pf in "$TARGET/setup.py" "$TARGET/pyproject.toml"; do
  [[ -f "$pf" ]] || continue
  echo "[INFO] Checking $pf..."
  if grep -nEi 'urllib|requests\.|http\.client|socket\.' "$pf" 2>/dev/null | grep -qv "^#"; then
    matches=$(grep -nEi 'urllib|requests\.|http\.client|socket\.' "$pf" 2>/dev/null | grep -v "^#")
    flag "HIGH" "$pf" "Network calls at install time:"
    echo "$matches" | head -5 | sed 's/^/  /'
  fi
  if grep -nEi 'subprocess|os\.system|os\.popen' "$pf" 2>/dev/null | grep -qv "^#"; then
    matches=$(grep -nEi 'subprocess|os\.system|os\.popen' "$pf" 2>/dev/null | grep -v "^#")
    flag "MEDIUM" "$pf" "Shell execution at install time:"
    echo "$matches" | head -5 | sed 's/^/  /'
  fi
done

# ── .yarnrc / .npmrc registry overrides ────────────────────────────────────────
for rc in "$TARGET/.yarnrc" "$TARGET/.yarnrc.yml"; do
  [[ -f "$rc" ]] || continue
  if grep -qi "registry\|npmRegistryServer" "$rc"; then
    flag "MEDIUM" "$rc" "Registry override (dependency confusion risk):"
    grep -i "registry\|npmRegistryServer" "$rc" | sed 's/^/  /'
  fi
done

[[ "$FOUND" -eq 0 ]] && echo "[INFO] No dangerous build script patterns found."
exit 0
