#!/usr/bin/env bash
# Audit CI/CD configs for supply chain and privilege escalation risks.
set -uo pipefail

TARGET="${1:-.}"

echo ""
echo "=== SCAN 05: CI/CD & Docker ==="

FOUND=0

flag() {
  local sev="$1" file="$2" msg="$3"
  echo "[$sev] $file"
  echo "  $msg"
  FOUND=1
}

# ── GitHub Actions ─────────────────────────────────────────────────────────────
GHA_DIR="$TARGET/.github/workflows"
if [[ -d "$GHA_DIR" ]]; then
  echo "[INFO] Scanning GitHub Actions workflows..."
  while IFS= read -r wf; do
    [[ -z "$wf" ]] && continue
    fname="${wf#$TARGET/}"

    # pull_request_target (allows write on external PRs — high-risk trigger)
    if grep -q "pull_request_target" "$wf" 2>/dev/null; then
      # Extra risky if combined with checkout of PR head
      if grep -q "ref.*head\|head_ref\|github.event.pull_request.head" "$wf" 2>/dev/null; then
        flag "CRITICAL" "$fname" "pull_request_target + PR head checkout = arbitrary code execution from forks"
      else
        flag "HIGH" "$fname" "pull_request_target trigger gives write permissions to external PRs"
      fi
    fi

    # Secrets passed to untrusted code
    if grep -q "pull_request" "$wf" && grep -q "secrets\." "$wf" 2>/dev/null; then
      if ! grep -q "pull_request_target" "$wf"; then
        # secrets in PR workflows without pull_request_target is usually fine
        true
      fi
    fi

    # Unpinned action versions
    while IFS= read -r line; do
      action=$(echo "$line" | grep -oE 'uses:\s*[^@]+@[^\s]+' | head -1 || true)
      [[ -z "$action" ]] && continue
      version=$(echo "$action" | cut -d@ -f2)
      # Flag if not a SHA (40 hex chars) and uses branch name
      if echo "$version" | grep -qE "^(main|master|HEAD|latest|v?[0-9]+)$"; then
        flag "MEDIUM" "$fname" "Unpinned action (branch ref is mutable): $action"
      fi
    done < <(grep -n "uses:" "$wf" 2>/dev/null || true)

    # External URL fetches in steps
    if grep -nEi 'curl|wget' "$wf" 2>/dev/null | grep -qv "^#"; then
      matches=$(grep -nEi 'curl|wget' "$wf" 2>/dev/null | grep -v "^#")
      flag "HIGH" "$fname" "Network fetch in workflow step:"
      echo "$matches" | sed 's/^/    /'
    fi

    # curl/wget piped to shell
    if grep -nEi '(curl|wget).*\|.*(bash|sh|python|node)' "$wf" 2>/dev/null | grep -q .; then
      matches=$(grep -nEi '(curl|wget).*\|.*(bash|sh|python|node)' "$wf")
      flag "CRITICAL" "$fname" "Remote script execution in workflow:"
      echo "$matches" | sed 's/^/    /'
    fi

    # Write permissions at workflow level
    if grep -A5 "^permissions:" "$wf" 2>/dev/null | grep -qE "write|all"; then
      flag "MEDIUM" "$fname" "Workflow requests broad write permissions"
    fi

  done < <(find "$GHA_DIR" \( -name "*.yml" -o -name "*.yaml" \) -print 2>/dev/null)
fi

# ── GitLab CI ──────────────────────────────────────────────────────────────────
if [[ -f "$TARGET/.gitlab-ci.yml" ]]; then
  echo "[INFO] Scanning .gitlab-ci.yml..."
  f="$TARGET/.gitlab-ci.yml"
  fname=".gitlab-ci.yml"

  if grep -nEi '(curl|wget).*\|.*(bash|sh)' "$f" 2>/dev/null | grep -q .; then
    flag "CRITICAL" "$fname" "Remote script execution:"
    grep -nEi '(curl|wget).*\|.*(bash|sh)' "$f" | sed 's/^/  /'
  fi
  if grep -nEi 'allow_failure:\s*true' "$f" 2>/dev/null | grep -q .; then
    echo "[INFO] $fname: allow_failure:true found (silences security scan failures)"
  fi
fi

# ── Dockerfiles ────────────────────────────────────────────────────────────────
while IFS= read -r df; do
  [[ -z "$df" ]] && continue
  fname="${df#$TARGET/}"
  echo "[INFO] Scanning $fname..."

  # FROM with non-official or untagged image
  while IFS= read -r line; do
    image=$(echo "$line" | grep -oE 'FROM\s+[^\s]+' | awk '{print $2}' || true)
    [[ -z "$image" ]] || [[ "$image" == "scratch" ]] && continue
    # Flag if no digest pin
    if ! echo "$image" | grep -qE "@sha256:"; then
      if ! echo "$image" | grep -qE "^(ubuntu|debian|alpine|python|node|golang|rust|nginx|redis|postgres|mysql|mongo)"; then
        flag "MEDIUM" "$fname" "FROM non-official base image (unpinned): $image"
      elif ! echo "$image" | grep -qE ":[0-9]"; then
        flag "LOW" "$fname" "FROM base image without version pin: $image"
      fi
    fi
  done < <(grep -i "^FROM" "$df" 2>/dev/null || true)

  # ADD from URL
  if grep -niE "^ADD\s+https?://" "$df" 2>/dev/null | grep -q .; then
    flag "HIGH" "$fname" "ADD fetches from URL (use COPY instead, verify integrity):"
    grep -niE "^ADD\s+https?://" "$df" | sed 's/^/  /'
  fi

  # RUN curl|wget | bash
  if grep -niE 'RUN.*(curl|wget).*\|.*(bash|sh)' "$df" 2>/dev/null | grep -q .; then
    flag "HIGH" "$fname" "RUN pipes remote script to shell:"
    grep -niE 'RUN.*(curl|wget).*\|.*(bash|sh)' "$df" | sed 's/^/  /'
  fi

done < <(find "$TARGET" -maxdepth 3 -name "Dockerfile*" -print 2>/dev/null)

# ── Pre-commit hooks ───────────────────────────────────────────────────────────
if [[ -f "$TARGET/.pre-commit-config.yaml" ]]; then
  echo "[INFO] Checking .pre-commit-config.yaml..."
  if grep -qEi 'http|curl|wget' "$TARGET/.pre-commit-config.yaml" 2>/dev/null; then
    flag "MEDIUM" ".pre-commit-config.yaml" "Remote fetch in pre-commit hook config"
  fi
  # Repos not pinned to rev
  if grep -A1 "^-\s*repo:" "$TARGET/.pre-commit-config.yaml" 2>/dev/null | grep -v "rev:" | grep -q "repo:"; then
    flag "LOW" ".pre-commit-config.yaml" "Some hooks may not be pinned to a rev"
  fi
fi

[[ "$FOUND" -eq 0 ]] && echo "[INFO] No CI/CD threats found."
exit 0
