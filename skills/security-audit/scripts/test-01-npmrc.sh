#!/usr/bin/env bash
# Check that 01-dependencies.sh never invokes npm inside a repo whose .npmrc
# redirects the registry. Run: bash test-01-npmrc.sh
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# npm shim: records every invocation instead of hitting the network
mkdir -p "$TMP/shim"
cat > "$TMP/shim/npm" <<'SHIM'
#!/usr/bin/env bash
echo "$*" >> "$NPM_MARKER"
echo '{"metadata":{"vulnerabilities":{"critical":0,"high":0,"moderate":0}},"vulnerabilities":{}}'
SHIM
chmod +x "$TMP/shim/npm"

mkdir -p "$TMP/hostile" "$TMP/clean"
echo '{"name":"x"}' > "$TMP/hostile/package.json"
printf 'registry=https://evil.example.com/\n' > "$TMP/hostile/.npmrc"
echo '{"name":"y"}' > "$TMP/clean/package.json"

fail=0

# 1. Hostile .npmrc — npm must NOT run.
export NPM_MARKER="$TMP/marker_hostile"; : > "$NPM_MARKER"
out=$(PATH="$TMP/shim:$PATH" bash "$HERE/01-dependencies.sh" "$TMP/hostile" 2>&1)
if [[ -s "$NPM_MARKER" ]]; then
  echo "FAIL: npm ran inside a repo with a registry override — $(cat "$NPM_MARKER")"; fail=1
fi
grep -q "Skipping npm audit" <<<"$out" || { echo "FAIL: no skip notice for hostile .npmrc"; fail=1; }
grep -q "^\[HIGH\] .npmrc overrides" <<<"$out" || { echo "FAIL: override not reported as HIGH"; fail=1; }

# 2. Clean repo — npm must run, and with an explicit registry the repo cannot override.
export NPM_MARKER="$TMP/marker_clean"; : > "$NPM_MARKER"
PATH="$TMP/shim:$PATH" bash "$HERE/01-dependencies.sh" "$TMP/clean" >/dev/null 2>&1
grep -q -- "--registry=https://registry.npmjs.org/" "$NPM_MARKER" \
  || { echo "FAIL: clean repo did not run npm audit with an explicit registry"; fail=1; }

[[ $fail -eq 0 ]] && echo "ok — 2/2" || exit 1
