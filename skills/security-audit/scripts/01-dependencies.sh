#!/usr/bin/env bash
# Audit dependencies for known vulnerabilities and supply chain risks.
set -uo pipefail

TARGET="${1:-.}"
cd "$TARGET" || { echo "[ERROR] Cannot cd to $TARGET"; exit 1; }

echo ""
echo "=== SCAN 01: Dependencies ==="

FOUND=0

# ── Node.js ────────────────────────────────────────────────────────────────────
if [[ -f package.json ]]; then
  echo ""
  echo "--- Node.js ---"

  # npm audit
  if command -v npm &>/dev/null; then
    echo "[INFO] Running npm audit..."
    AUDIT=$(npm audit --json 2>/dev/null || true)
    if [[ -n "$AUDIT" ]]; then
      # Extract high/critical counts
      CRITICAL=$(echo "$AUDIT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('metadata',{}).get('vulnerabilities',{}).get('critical',0))" 2>/dev/null || echo 0)
      HIGH=$(echo "$AUDIT"     | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('metadata',{}).get('vulnerabilities',{}).get('high',0))"     2>/dev/null || echo 0)
      MODERATE=$(echo "$AUDIT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('metadata',{}).get('vulnerabilities',{}).get('moderate',0))" 2>/dev/null || echo 0)
      [[ "$CRITICAL" -gt 0 ]] && echo "[CRITICAL] npm audit: $CRITICAL critical vulnerabilities" && FOUND=1
      [[ "$HIGH" -gt 0 ]]     && echo "[HIGH]     npm audit: $HIGH high vulnerabilities" && FOUND=1
      [[ "$MODERATE" -gt 0 ]] && echo "[MEDIUM]   npm audit: $MODERATE moderate vulnerabilities" && FOUND=1
      # Print individual advisories
      echo "$AUDIT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
vulns = d.get('vulnerabilities', {})
for name, info in vulns.items():
    sev = info.get('severity','').upper()
    via = info.get('via', [])
    for v in via:
        if isinstance(v, dict):
            title = v.get('title','')
            url   = v.get('url','')
            print(f'  [{sev}] {name}: {title} {url}')
" 2>/dev/null || true
    fi
  fi

  # Typosquatting check
  echo "[INFO] Checking for typosquatted package names..."
  SQUATTING_TARGETS=(
    "lodash:lodassh,l0dash,Iodash"
    "express:expres,xpress,expresss"
    "react:reakt,raect,reeact"
    "axios:axois,axio,axxios"
    "moment:momment,moement"
    "webpack:webpak,web-pack"
    "requests:request5,reuqests,requets"
    "numpy:nunpy,nurnpy,numy"
    "django:diango,djang0"
    "flask:flsk,flassk"
    "colors:color5,c0lors"
    "faker:fakerjs,fakerf"
    "cross-env:crossenv,cross_env"
    "event-stream:eventstream,event_stream"
  )
  PKGS=$(python3 -c "
import json, sys
try:
    d = json.load(open('package.json'))
    deps = {}
    deps.update(d.get('dependencies', {}))
    deps.update(d.get('devDependencies', {}))
    print(' '.join(deps.keys()))
except: pass
" 2>/dev/null || true)

  for pair in "${SQUATTING_TARGETS[@]}"; do
    canonical="${pair%%:*}"
    fakes="${pair##*:}"
    IFS=',' read -ra FAKE_LIST <<< "$fakes"
    for fake in "${FAKE_LIST[@]}"; do
      if echo "$PKGS" | grep -qw "$fake"; then
        echo "[HIGH] Typosquatting suspect: '$fake' (looks like '$canonical')"
        FOUND=1
      fi
    done
  done

  # Check .npmrc for registry overrides (dependency confusion)
  if [[ -f .npmrc ]]; then
    if grep -q "registry" .npmrc; then
      echo "[MEDIUM] .npmrc contains registry override — check for dependency confusion:"
      grep "registry" .npmrc | sed 's/^/  /'
      FOUND=1
    fi
  fi
fi

# ── Python ─────────────────────────────────────────────────────────────────────
if [[ -f requirements.txt ]] || [[ -f pyproject.toml ]] || [[ -f setup.py ]]; then
  echo ""
  echo "--- Python ---"

  if command -v pip-audit &>/dev/null; then
    echo "[INFO] Running pip-audit..."
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      echo "[HIGH] $line"
      FOUND=1
    done < <(pip-audit --format columns 2>/dev/null | grep -v "^No known" | grep -v "^Name" | grep -v "^---")
  elif command -v safety &>/dev/null; then
    echo "[INFO] Running safety check..."
    while IFS= read -r line; do
      echo "[HIGH] $line"
      FOUND=1
    done < <(safety check 2>/dev/null | grep -i "vulnerability")
  else
    echo "[INFO] pip-audit not installed — skipping Python vuln scan (run: pip install pip-audit)"
  fi

  # Check for --extra-index-url (dependency confusion)
  for f in requirements*.txt; do
    [[ -f "$f" ]] || continue
    if grep -q "extra-index-url\|trusted-host\|index-url" "$f" 2>/dev/null; then
      echo "[MEDIUM] $f contains custom index URL — dependency confusion risk:"
      grep -n "extra-index-url\|trusted-host\|index-url" "$f" | sed 's/^/  /'
      FOUND=1
    fi
  done
fi

# ── Rust ───────────────────────────────────────────────────────────────────────
if [[ -f Cargo.toml ]]; then
  echo ""
  echo "--- Rust ---"
  if command -v cargo-audit &>/dev/null || (command -v cargo &>/dev/null && cargo audit --version &>/dev/null 2>&1); then
    echo "[INFO] Running cargo audit..."
    while IFS= read -r line; do
      echo "[HIGH] $line"
      FOUND=1
    done < <(cargo audit 2>/dev/null | grep -E "error\[|warning\[")
  else
    echo "[INFO] cargo-audit not installed — skipping (run: cargo install cargo-audit)"
  fi
fi

# ── Go ─────────────────────────────────────────────────────────────────────────
if [[ -f go.mod ]]; then
  echo ""
  echo "--- Go ---"
  if command -v govulncheck &>/dev/null; then
    echo "[INFO] Running govulncheck..."
    while IFS= read -r line; do
      echo "[HIGH] $line"
      FOUND=1
    done < <(govulncheck ./... 2>/dev/null | grep -iE "vulnerability|GO-[0-9]{4}-")
  else
    echo "[INFO] govulncheck not installed — skipping Go vuln scan (run: go install golang.org/x/vuln/cmd/govulncheck@latest)"
  fi
fi

# ── pnpm / bun / deno ──────────────────────────────────────────────────────────
if [[ -f pnpm-lock.yaml ]] && command -v pnpm &>/dev/null; then
  echo ""
  echo "--- pnpm ---"
  echo "[INFO] Running pnpm audit..."
  while IFS= read -r line; do
    echo "[HIGH] $line"
    FOUND=1
  done < <(pnpm audit 2>/dev/null | grep -iE "critical|high|moderate|advisory")
fi
if [[ -f bun.lockb ]]; then
  echo ""
  echo "--- bun ---"
  echo "[INFO] bun lockfile present — osv-scanner (below) covers it; 'bun audit' has no offline mode."
fi
if [[ -f deno.json ]] || [[ -f deno.jsonc ]] || [[ -f deno.lock ]]; then
  echo ""
  echo "--- deno ---"
  echo "[INFO] Deno project — osv-scanner (below) reads deno.lock; review import URLs manually for pinning."
fi

# ── OSV Scanner (all ecosystems) ───────────────────────────────────────────────
if command -v osv-scanner &>/dev/null; then
  echo ""
  echo "--- OSV Scanner ---"
  OSV_OUT=$(osv-scanner --format table . 2>/dev/null || true)
  # osv-scanner logs progress ("Scanning dir", "Starting filesystem walk", "End
  # status…") to stdout — only surface rows that carry an actual advisory ID.
  OSV_HITS=$(echo "$OSV_OUT" | grep -E 'GHSA-|CVE-|OSV-|RUSTSEC-|PYSEC-|GO-[0-9]{4}|MAL-' | grep -viE 'no known|^\s*$' || true)
  if [[ -n "$OSV_HITS" ]]; then
    while IFS= read -r line; do
      echo "[HIGH] $line"
      FOUND=1
    done < <(echo "$OSV_HITS")
  fi
fi

[[ "$FOUND" -eq 0 ]] && echo "[INFO] No dependency vulnerabilities found."
exit 0
