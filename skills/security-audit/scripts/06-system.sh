#!/usr/bin/env bash
# Full host system scan: launch agents, cron, global packages, network, ClamAV.
set -uo pipefail

echo ""
echo "=== SCAN 06: System Scan ==="

FOUND=0

flag() {
  echo "[$1] $2"
  [[ -n "${3:-}" ]] && echo "  $3"
  FOUND=1
}

# ── macOS Launch Agents / Daemons ──────────────────────────────────────────────
echo ""
echo "--- Launch Agents & Daemons ---"

LA_DIRS=(
  "$HOME/Library/LaunchAgents"
  "/Library/LaunchAgents"
  "/Library/LaunchDaemons"
  "/System/Library/LaunchAgents"
  "/System/Library/LaunchDaemons"
)

for dir in "${LA_DIRS[@]}"; do
  [[ -d "$dir" ]] || continue
  echo "[INFO] $dir:"

  # Items added/modified in last 30 days
  recent=$(find "$dir" -name "*.plist" -mtime -30 2>/dev/null | sort)
  if [[ -n "$recent" ]]; then
    echo "[MEDIUM] Recently modified plist files (last 30 days) in $dir:"
    echo "$recent" | sed 's/^/  /'
    FOUND=1
  fi

  # List all for LLM review
  ls "$dir" 2>/dev/null | sed 's/^/  [INFO] /'

  # Check for network-related launch agents
  while IFS= read -r plist; do
    if grep -qEi "curl|wget|http|socket|nc |ncat" "$plist" 2>/dev/null; then
      flag "HIGH" "$plist" "Launch agent/daemon contains network commands"
    fi
    # RunAtLoad with unusual Program path
    prog=$(plutil -extract ProgramArguments xml1 -o - "$plist" 2>/dev/null | grep -oE '<string>[^<]+</string>' | head -1 | tr -d '<string></string>' || true)
    if [[ -n "$prog" ]] && [[ ! "$prog" =~ ^(/usr|/bin|/sbin|/System|/Applications) ]]; then
      flag "MEDIUM" "$plist" "Launch item runs program outside standard paths: $prog"
    fi
  done < <(find "$dir" -name "*.plist" 2>/dev/null)
done

# ── Cron ───────────────────────────────────────────────────────────────────────
echo ""
echo "--- Cron Jobs ---"
crontab_content=$(crontab -l 2>/dev/null || true)
if [[ -n "$crontab_content" ]]; then
  echo "[INFO] User crontab:"
  echo "$crontab_content" | sed 's/^/  /'
  if echo "$crontab_content" | grep -qEi 'curl|wget|http|base64'; then
    flag "HIGH" "crontab" "Cron job contains network/decode command"
  fi
else
  echo "[INFO] No user crontab found."
fi

if [[ -d /etc/cron.d ]] || ls /etc/cron* &>/dev/null 2>&1; then
  echo "[INFO] System cron directories:"
  ls /etc/cron* 2>/dev/null | sed 's/^/  /'
fi

# ── Globally installed packages ────────────────────────────────────────────────
echo ""
echo "--- Global Package Installs (for LLM review) ---"

if command -v npm &>/dev/null; then
  echo "[INFO] Global npm packages:"
  npm list -g --depth=0 2>/dev/null | sed 's/^/  /' || true
fi

if command -v pip &>/dev/null || command -v pip3 &>/dev/null; then
  echo "[INFO] Global pip packages:"
  (pip list 2>/dev/null || pip3 list 2>/dev/null) | sed 's/^/  /' || true
fi

if command -v brew &>/dev/null; then
  echo "[INFO] Homebrew installed formulae:"
  brew list --formula 2>/dev/null | tr '\n' ' ' | fold -s -w 80 | sed 's/^/  /' || true
fi

# ── Active network connections ─────────────────────────────────────────────────
echo ""
echo "--- Active Network Connections (for LLM review) ---"
if command -v lsof &>/dev/null; then
  echo "[INFO] ESTABLISHED connections:"
  lsof -i -n -P 2>/dev/null | grep ESTABLISHED | sed 's/^/  /' | head -40 || true
fi

# ── Suspicious processes ───────────────────────────────────────────────────────
echo ""
echo "--- Process Check ---"
# Look for processes with common miner/RAT names
SUSPICIOUS_PROCS=(xmrig minerd kdevtmpfsi kinsing cryptonight masscan zmap)
for proc in "${SUSPICIOUS_PROCS[@]}"; do
  if pgrep -x "$proc" &>/dev/null 2>&1; then
    flag "CRITICAL" "process:$proc" "Known malicious process name detected"
  fi
done

# ── ClamAV scan ────────────────────────────────────────────────────────────────
echo ""
echo "--- ClamAV ---"
if command -v clamscan &>/dev/null; then
  echo "[INFO] Running ClamAV on ~/Downloads and ~/Desktop..."
  clamscan -r --max-filesize=50M --max-scansize=100M \
    --infected --no-summary \
    "$HOME/Downloads" "$HOME/Desktop" 2>/dev/null | while IFS= read -r line; do
      echo "[CRITICAL] ClamAV: $line"
      FOUND=1
    done || true
  echo "[INFO] ClamAV scan complete."
else
  echo "[INFO] ClamAV not installed (brew install clamav && freshclam for AV coverage)"
fi

# ── SSH authorized_keys anomalies ─────────────────────────────────────────────
echo ""
echo "--- SSH Authorized Keys ---"
if [[ -f "$HOME/.ssh/authorized_keys" ]]; then
  count=$(wc -l < "$HOME/.ssh/authorized_keys")
  echo "[INFO] ~/.ssh/authorized_keys: $count keys"
  if [[ "$count" -gt 5 ]]; then
    flag "MEDIUM" "~/.ssh/authorized_keys" "$count authorized keys — verify all are expected"
  fi
  cat "$HOME/.ssh/authorized_keys" | sed 's/^/  [INFO] /'
fi

[[ "$FOUND" -eq 0 ]] && echo "[INFO] No system threats detected."
echo ""
echo "=== System scan complete. Review [INFO] lists above with LLM for novel threats. ==="
exit 0
