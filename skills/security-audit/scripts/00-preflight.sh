#!/usr/bin/env bash
# Check for optional scanning tools and report availability.
set -euo pipefail

echo "=== PREFLIGHT: Tool Availability ==="

check_tool() {
  local cmd="$1"
  local install_hint="$2"
  if command -v "$cmd" &>/dev/null; then
    echo "[OK]      $cmd"
  else
    echo "[MISSING] $cmd  →  install: $install_hint"
  fi
}

check_tool npm        "brew install node"
check_tool pip        "brew install python"
check_tool pip-audit  "pip install pip-audit"
check_tool osv-scanner "brew install osv-scanner"
check_tool cargo      "brew install rust"
check_tool cargo-audit "cargo install cargo-audit"
check_tool govulncheck "go install golang.org/x/vuln/cmd/govulncheck@latest"
check_tool semgrep    "brew install semgrep"
check_tool gitleaks   "brew install gitleaks"
check_tool trufflehog "brew install trufflehog"
check_tool trivy      "brew install trivy"
check_tool clamscan   "brew install clamav && freshclam"

echo ""
echo "Missing tools are skipped gracefully. Install them for deeper coverage."
exit 0
