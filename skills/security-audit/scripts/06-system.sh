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

# ── Configuration Profiles / MDM ───────────────────────────────────────────────
echo ""
echo "--- Configuration Profiles & MDM ---"
# A rogue config profile can install a CA, route traffic, or force settings — top backdoor vector.
enroll=$(profiles status -type enrollment 2>/dev/null || true)
if [[ -n "$enroll" ]]; then
  echo "$enroll" | sed 's/^/  [INFO] /'
  if echo "$enroll" | grep -qiE 'MDM enrollment:\s*Yes'; then
    flag "MEDIUM" "MDM enrolled" "Device is MDM-enrolled — confirm the management authority is expected"
  fi
fi
# Full profile list needs root; note when we cannot read it.
if profiles list -all &>/dev/null; then
  profiles list -all 2>/dev/null | sed 's/^/  [INFO] /' | head -20
else
  echo "  [INFO] profile payload list requires root — re-run with sudo for full coverage"
fi

# ── System / Kernel Extensions ─────────────────────────────────────────────────
echo ""
echo "--- System & Kernel Extensions ---"
if command -v systemextensionsctl &>/dev/null; then
  systemextensionsctl list 2>/dev/null | grep -E '\[activated|\[terminated|teamID' | sed 's/^/  [INFO] /' | head -20
fi

# ── Login Items ────────────────────────────────────────────────────────────────
echo ""
echo "--- Login Items ---"
osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null \
  | tr ',' '\n' | sed 's/^ */  [INFO] /' || echo "  [INFO] none / not readable"

# ── Shell RC integrity ─────────────────────────────────────────────────────────
echo ""
echo "--- Shell Startup Files ---"
for rc in "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile" "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.profile"; do
  [[ -f "$rc" ]] || continue
  hits=$(grep -nE 'curl|wget|base64 -d|/tmp/|nc -|ncat|\| *sh' "$rc" 2>/dev/null | grep -vE 'brew shellenv|pyenv init|thefuck|nvm.sh|rbenv|# ' || true)
  if [[ -n "$hits" ]]; then
    flag "HIGH" "$rc" "Startup file has network/decode/temp-exec lines — review:"
    echo "$hits" | sed 's/^/    /'
  fi
done

# ── Sudoers drop-ins ───────────────────────────────────────────────────────────
echo ""
echo "--- Sudoers ---"
if [[ -r /etc/sudoers ]]; then
  grep -rEn 'NOPASSWD|!authenticate' /etc/sudoers /etc/sudoers.d/ 2>/dev/null \
    | sed 's/^/  [MEDIUM] /' || echo "  [INFO] no NOPASSWD entries"
else
  ls -la /etc/sudoers.d/ 2>/dev/null | sed 's/^/  [INFO] /'
  echo "  [INFO] sudoers content requires root — re-run with sudo to check NOPASSWD"
fi

# ── Listening ports (inbound exposure) ─────────────────────────────────────────
echo ""
echo "--- Listening Ports (non-loopback) ---"
if command -v lsof &>/dev/null; then
  while IFS= read -r line; do
    echo "  [INFO] $line"
    # Flag listeners bound to all interfaces owned by non-Apple processes
    if echo "$line" | grep -qE '\*:[0-9]|0\.0\.0\.0:[0-9]'; then
      pcmd=$(echo "$line" | awk '{print $1}')
      case "$pcmd" in
        rapportd|sharingd|ControlCe|launchd|systemstat|remoted) : ;;  # known Apple
        *) flag "MEDIUM" "listener:$pcmd" "Non-Apple process listening on all interfaces: $line" ;;
      esac
    fi
  done < <(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1 && $9 !~ /127\.0\.0\.1|\[::1\]/')
fi

# ── Proxy / hosts / DNS tampering ──────────────────────────────────────────────
echo ""
echo "--- Proxy & Hosts ---"
if command -v scutil &>/dev/null; then
  prox=$(scutil --proxy 2>/dev/null | grep -iE 'ProxyEnable|Proxy :|HTTPSEnable|SOCKSEnable' | grep -E ': 1$' || true)
  [[ -n "$prox" ]] && flag "MEDIUM" "system proxy" "A system proxy is enabled — confirm it is yours (MITM risk):" && echo "$prox" | sed 's/^/    /'
fi
custom_hosts=$(grep -vE '^\s*#|^\s*$|127\.0\.0\.1|::1|broadcasthost|255\.255|fe80' /etc/hosts 2>/dev/null || true)
[[ -n "$custom_hosts" ]] && flag "MEDIUM" "/etc/hosts" "Custom host overrides present — confirm none redirect known domains:" && echo "$custom_hosts" | sed 's/^/    /'

# ── Inbound sharing services ───────────────────────────────────────────────────
echo ""
echo "--- Remote Access Services ---"
rl=$(systemsetup -getremotelogin 2>/dev/null || echo "requires root")
echo "  [INFO] Remote Login (SSH server): $rl"
echo "$rl" | grep -qi 'On' && flag "MEDIUM" "Remote Login" "SSH server is ON — confirm intentional and key-only"
launchctl list 2>/dev/null | grep -iE 'screensharing|RemoteDesktop|smbd' | grep -vE '^\-\s+0' | sed 's/^/  [INFO] active: /' || true

# ── Tailscale deep inspection ──────────────────────────────────────────────────
echo ""
echo "--- Tailscale / Tailnet ---"
if command -v tailscale &>/dev/null; then
  serve=$(tailscale serve status 2>/dev/null || true)
  [[ -n "$serve" && "$serve" != *"No serve config"* ]] && flag "MEDIUM" "tailscale serve" "Local service exposed to tailnet — confirm intended:" && echo "$serve" | sed 's/^/    /'
  funnel=$(tailscale funnel status 2>/dev/null || true)
  echo "$funnel" | grep -qiE 'https://.*(:443|/)\s' && echo "$funnel" | grep -qvi 'tailnet only' && flag "HIGH" "tailscale funnel" "Service exposed to the PUBLIC internet via Funnel:" && echo "$funnel" | sed 's/^/    /'
  tailscale lock status 2>/dev/null | grep -qi 'NOT enabled' && flag "MEDIUM" "tailnet lock" "Tailnet Lock disabled — rogue nodes can join without signed key approval"
  tailscale debug prefs 2>/dev/null | grep -q '"ShieldsUp": false' && flag "LOW" "tailscale shields" "ShieldsUp off — any tailnet peer can initiate inbound to this node"
fi

# ── Agent / automation surface (Claude Code, headless agents) ──────────────────
echo ""
echo "--- Agent Surface (hooks / MCP / autorun) ---"
# Hooks and MCP servers run arbitrary code with your credentials. Enumerate, do not trust blindly.
for sf in "$HOME/.claude/settings.json" "$HOME/.claude/settings.local.json"; do
  [[ -f "$sf" ]] || continue
  echo "  [INFO] $sf hooks:"
  python3 - "$sf" <<'PY' 2>/dev/null || echo "    (parse skipped)"
import json,sys
d=json.load(open(sys.argv[1]))
for k,v in d.get('hooks',{}).items():
    for m in v:
        for e in m.get('hooks',[]):
            print("    %s | %s" % (e.get('type'), (e.get('command','')[:100])))
PY
done
# MCP servers (per-project in ~/.claude.json)
python3 - <<'PY' 2>/dev/null || true
import json,os
p=os.path.expanduser('~/.claude.json')
if os.path.exists(p):
    d=json.load(open(p))
    servers=set()
    for proj in d.get('projects',{}).values():
        servers.update((proj.get('mcpServers') or {}).keys())
    if servers: print("  [INFO] MCP servers configured:", ", ".join(sorted(servers)))
PY

# ── Credential exposure (names/perms only — never print values) ────────────────
echo ""
echo "--- Credential Exposure ---"
# Plaintext secrets exported in dotfiles
secnames=$(grep -hoE '^export [A-Z_]*(TOKEN|KEY|SECRET|PASSWORD|PAT|APIKEY)[A-Z_]*' \
  "$HOME/.zshenv" "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bash_profile" 2>/dev/null | sort -u || true)
[[ -n "$secnames" ]] && flag "MEDIUM" "dotfile secrets" "Plaintext secrets exported in shell dotfiles (readable by any process you run):" && echo "$secnames" | sed 's/^/    /'
# git credential.helper=store writes plaintext
[[ "$(git config --global credential.helper 2>/dev/null)" == "store" ]] && flag "MEDIUM" "git credential store" "git credential.helper=store keeps passwords plaintext in ~/.git-credentials"
[[ -f "$HOME/.git-credentials" ]] && flag "MEDIUM" "~/.git-credentials" "Plaintext git credentials file present"
# SSH private keys without passphrase
for k in "$HOME"/.ssh/id_*; do
  [[ -f "$k" && "$k" != *.pub ]] || continue
  # Reliable across key formats: unlocking with an EMPTY passphrase succeeds only when
  # the key has no passphrase. grep 'ENCRYPTED' gives false negatives on OpenSSH-format keys.
  if ssh-keygen -y -f "$k" -P '' >/dev/null 2>&1; then
    flag "HIGH" "$(basename "$k")" "SSH private key has NO passphrase — a copy of the file grants access directly"
  fi
done
# Secrets pasted into shell history (count only)
for h in "$HOME/.zsh_history" "$HOME/.bash_history"; do
  [[ -f "$h" ]] || continue
  n=$(grep -icE 'ghp_|gho_|sk-[a-z]|AKIA|ntn_|xoxb-|Bearer [A-Za-z0-9]{20}|password=|api_key=' "$h" 2>/dev/null || echo 0)
  [[ "$n" -gt 0 ]] && flag "MEDIUM" "$(basename "$h")" "$n line(s) look like pasted secrets — persisted plaintext forever"
done
# Cloud credential dirs (presence)
for d in "$HOME/.aws" "$HOME/.config/gcloud" "$HOME/.kube" "$HOME/.config/gh" "$HOME/.azure"; do
  [[ -e "$d" ]] && echo "  [INFO] cloud creds present: $d"
done

# ── Binary integrity in user PATH ──────────────────────────────────────────────
echo ""
echo "--- Binary Signatures (~/.local/bin, /usr/local/bin) ---"
if command -v codesign &>/dev/null; then
  for b in "$HOME"/.local/bin/* /usr/local/bin/*; do
    [[ -f "$b" && -x "$b" ]] || continue
    # Only meaningful for compiled binaries — scripts have no code signature by design.
    file "$b" 2>/dev/null | grep -q 'Mach-O' || continue
    auth=$(codesign -dv --verbose=2 "$b" 2>&1 | grep -m1 'Authority=' | sed 's/Authority=//' || true)
    if [[ -z "$auth" ]]; then
      flag "MEDIUM" "$b" "Unsigned Mach-O binary in PATH — verify origin"
    else
      echo "  [INFO] $(basename "$b"): signed by $auth"
    fi
  done | head -40
fi

# ── OS patch level & hardening posture ─────────────────────────────────────────
echo ""
echo "--- Patch & Hardening Posture ---"
upd=$(softwareupdate -l 2>&1 | grep -iE 'Recommended: YES|restart' | head || true)
[[ -n "$upd" ]] && flag "LOW" "pending updates" "OS/security updates available:" && echo "$upd" | sed 's/^/    /'
sysadminctl -screenLock status 2>&1 | grep -qi 'immediate' || flag "MEDIUM" "screen lock" "Screen lock is not immediate — set to require password immediately"
sysadminctl -guestAccount status 2>&1 | grep -qi 'disabled' || flag "MEDIUM" "guest account" "Guest account is enabled — disable it"

# ═══════════════════════════════════════════════════════════════════════════════
# COMPROMISE INDICATORS (IOC) — is someone ALREADY inside? (distinct from hardening)
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo "=== SCAN 06-IOC: Compromise Detection ==="

# ── Processes running from world-writable temp dirs (classic malware drop) ──────
echo ""
echo "--- IOC: processes from temp/writable paths ---"
ps -axo pid,user,args 2>/dev/null | awk '$3 ~ /^\/(tmp|var\/tmp|private\/tmp|private\/var\/tmp|dev\/shm)\// {print $0}' \
  | while IFS= read -r p; do flag "HIGH" "temp-exec" "Process running from a writable temp dir: $p"; done
echo "  [INFO] (no HIGH above = none)"

# ── dylib injection via DYLD_INSERT_LIBRARIES in launch items ───────────────────
echo ""
echo "--- IOC: DYLD injection in launch items ---"
grep -rliE 'DYLD_INSERT|DYLD_LIBRARY' "$HOME/Library/LaunchAgents" /Library/LaunchAgents /Library/LaunchDaemons 2>/dev/null \
  | while IFS= read -r f; do flag "HIGH" "$f" "Launch item sets DYLD_INSERT_LIBRARIES (dylib hijack)"; done
echo "  [INFO] (no HIGH above = none)"

# ── Login history & active sessions (remote logins are the red flag) ────────────
echo ""
echo "--- IOC: login history & sessions ---"
last -8 2>/dev/null | grep -vE '^$|wtmp begins' | sed 's/^/  [INFO] /'
# A login source that is an IP/hostname (not blank/console/tty) = remote access
if last -20 2>/dev/null | awk '{print $3}' | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
  flag "HIGH" "remote login" "Remote login source found in history — confirm it was you"
fi
who 2>/dev/null | sed 's/^/  [INFO] session: /'

# ── Users & admin membership (ghost accounts / unexpected admins) ───────────────
echo ""
echo "--- IOC: users & admin group ---"
dscl . -list /Users UniqueID 2>/dev/null | awk '$2>=500 {print "  [INFO] account: "$1" (uid "$2")"}'
dscl . -read /Groups/admin GroupMembership 2>/dev/null | sed 's/^/  [INFO] /'

# ── authorized_keys across ALL users (ssh backdoor) ─────────────────────────────
echo ""
echo "--- IOC: authorized_keys (all users) ---"
akf=0
for ak in /Users/*/.ssh/authorized_keys /var/root/.ssh/authorized_keys; do
  [[ -f "$ak" ]] || continue
  akf=1
  flag "MEDIUM" "$ak" "authorized_keys present ($(wc -l <"$ak" | tr -d ' ') key(s)) — verify every key is yours"
done
[[ "$akf" -eq 0 ]] && echo "  [INFO] no authorized_keys anywhere (no ssh entry)"

# ── Manually-trusted certificates (rogue CA = silent MITM) ──────────────────────
echo ""
echo "--- IOC: manually-trusted certs ---"
ncert=$(security dump-trust-settings 2>/dev/null | grep -c 'Cert ' || echo 0)
if [[ "${ncert:-0}" -gt 0 ]]; then
  flag "MEDIUM" "user trust store" "$ncert manually-trusted cert(s) — confirm none is a rogue MITM CA:"
  security dump-trust-settings 2>/dev/null | grep -iE 'Cert [0-9]' | sed 's/^/    /'
else
  echo "  [INFO] no user-added trust overrides"
fi

# ── TCC: apps holding keylogger/exfil-grade privacy grants ──────────────────────
echo ""
echo "--- IOC: TCC privacy grants (accessibility/full-disk/screen) ---"
tcc="$HOME/Library/Application Support/com.apple.TCC/TCC.db"
if grants=$(sqlite3 "$tcc" "select client from access where service in ('kTCCServiceAccessibility','kTCCServiceSystemPolicyAllFiles','kTCCServiceScreenCapture','kTCCServiceListenEvent') and auth_value>0;" 2>/dev/null) && [[ -n "$grants" ]]; then
  echo "$grants" | while IFS= read -r c; do flag "LOW" "$c" "Holds accessibility/full-disk/screen grant — confirm it is trusted software"; done
else
  echo "  [INFO] TCC.db not readable (SIP) or no grants — verify in System Settings > Privacy"
fi

# ── Outbound to non-loopback, non-web ports (C2 / reverse shell) ────────────────
echo ""
echo "--- IOC: suspicious outbound (possible C2) ---"
if command -v lsof &>/dev/null; then
  lsof -nP -iTCP -sTCP:ESTABLISHED 2>/dev/null | awk 'NR>1 {
    split($9,a,"->");
    if (a[2] !~ /:(443|80|53|22|993|587|465|5223|5228)$/ && a[2] !~ /(127\.0\.0\.1|\[::1\])/)
      print $1" "$9 }' \
    | grep -viE 'rapportd|identity' \
    | while IFS= read -r c; do flag "MEDIUM" "outbound" "Non-web outbound (verify not C2): $c"; done
fi
echo "  [INFO] (loopback filtered; no MEDIUM above = only normal web)"

[[ "$FOUND" -eq 0 ]] && echo "[INFO] No system threats detected."
echo ""
echo "=== System scan complete. Review [INFO] lists above with LLM for novel threats. ==="
exit 0
