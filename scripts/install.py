#!/usr/bin/env python3
"""wibx-skills public installer — core token economy pack + full skills catalog.

Self-contained (stdlib only), ZERO devkit dependency. Mirrors the proven install
steps devkit uses internally, but public + user-scope so anyone who has the public
wibx-skills repo can get the pack on their machine.

Installs, into ~/.claude (user scope, shared by Claude Code CLI + IDE + Code GUI):
  - host tools:  rtk (binary -> ~/.local/bin), graphify (pip)   [SHA-pinned in install/pins.json]
  - plugins:     wibx-skills, caveman, ponytail  (via `claude plugin`, from the wibx-skills marketplace)
  - settings:    ~/.claude/settings.json  <- enabledPlugins + marketplace + economy env + rtk/graphify hooks (merged, never clobbered)
  - skills:      the full catalog, symlinked via scripts/skill_management.py --sync

Claude Desktop / claude.ai web cannot run hooks/binaries/plugins — see --desktop for the
best-effort path (.skill upload + pasted caveman/ponytail preamble).

Usage:  python3 scripts/install.py [--tools-only|--skills-only] [--no-tools] [--desktop] [--dry-run] [--check]
Normally invoked through the repo-root install.sh bootstrap.
"""
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
PINS = REPO / "install" / "pins.json"
_HEXSHA = re.compile(r"^[0-9a-f]{7,40}$")

# ---- output -------------------------------------------------------------- #
_TTY = sys.stdout.isatty() and not os.environ.get("NO_COLOR")
def _c(code):  # colorize when on a tty
    return (lambda s: f"\033[{code}m{s}\033[0m") if _TTY else (lambda s: s)
OK, NO, DIM, BOLD, CYAN = _c("1;32"), _c("1;31"), _c("2"), _c("1"), _c("1;36")

DRY = False
def say(msg):   print(msg)
def ok(msg):    say(f"{OK('✓')} {msg}")
def no(msg):    say(f"{NO('✗')} {msg}")
def skip(msg):  say(f"{DIM('·')} {msg}")

def run(cmd, **kw):
    """Run argv (or shell string). In --dry-run, print and do nothing."""
    shown = cmd if isinstance(cmd, str) else " ".join(cmd)
    if DRY:
        say(f"  {DIM('would run:')} {shown}")
        return 0
    return subprocess.run(cmd, **kw).returncode

# ---- pins ---------------------------------------------------------------- #
def load_pins():
    data = json.loads(PINS.read_text(encoding="utf-8"))
    data.setdefault("economy", {})
    # env overrides win over the pinned default
    data["economy"]["caveman_mode"] = os.environ.get(
        "WIBX_CAVEMAN_MODE", data["economy"].get("caveman_mode", "full"))
    data["economy"]["ponytail_mode"] = os.environ.get(
        "WIBX_PONYTAIL_MODE", data["economy"].get("ponytail_mode", "full"))
    return data

# ---- host tools ---------------------------------------------------------- #
def rtk_present():
    return bool(shutil.which("rtk")) or (Path.home() / ".local" / "bin" / "rtk").exists()

def rtk_install_commands(tool, platform=sys.platform):
    repo, ref = tool["repo"], tool.get("ref")
    cmds = []
    if platform.startswith(("linux", "darwin")):
        url = f"https://raw.githubusercontent.com/{repo}/{ref or 'HEAD'}/install.sh"
        prefix = f"RTK_VERSION={ref} " if ref else ""
        cmds.append(["sh", "-c", f"curl -fsSL {url} | {prefix}sh"])
    cargo = ["cargo", "install", "--git", f"https://github.com/{repo}"]
    if ref:
        cargo += (["--rev", str(ref)] if _HEXSHA.match(str(ref)) else ["--tag", str(ref)])
    cmds.append(cargo)
    return cmds

def ensure_rtk(pins):
    tool = pins["tools"]["rtk"]
    if rtk_present():
        ok("rtk present")
        return
    for cmd in rtk_install_commands(tool):
        if cmd[0] == "cargo" and not shutil.which("cargo"):
            continue
        if cmd[0] == "sh" and not shutil.which("curl"):
            continue
        run(cmd, check=False)
        if DRY or rtk_present():
            ok("rtk installed (ensure ~/.local/bin is on PATH)")
            return
    no("rtk not installed — needs curl+network (Linux/macOS) or cargo (Windows). "
       "The rtk hook no-ops until present.")

def graphify_present():
    try:
        return subprocess.run([sys.executable, "-c", "import graphify"],
                              capture_output=True).returncode == 0
    except Exception:
        return False

def graphify_install_command(tool):
    # dist name is `graphifyy` (double-y); import name is `graphify`.
    spec = f"graphifyy @ git+https://github.com/{tool['repo']}"
    if tool.get("ref"):
        spec += f"@{tool['ref']}"
    return [sys.executable, "-m", "pip", "install", spec]

def ensure_graphify(pins):
    tool = pins["tools"]["graphify"]
    if graphify_present():
        ok("graphify importable")
        return
    if not DRY and not shutil.which("pip") and \
            subprocess.run([sys.executable, "-m", "pip", "--version"],
                           capture_output=True).returncode != 0:
        no("graphify skipped — no pip. Graphify git hooks exit 0 while absent.")
        return
    run(graphify_install_command(tool), check=False)
    if not DRY and not graphify_present():
        run(graphify_install_command(tool) + ["--user"], check=False)  # PEP-668 fallback
    if DRY or graphify_present():
        ok("graphify installed")
    else:
        no("graphify not importable — pip failed/offline or PEP-668 env. "
           "Graphify git hooks exit 0 while absent.")

def install_tools(pins):
    say(BOLD("→ Host tools (rtk, graphify)"))
    ensure_rtk(pins)
    ensure_graphify(pins)

# ---- claude plugins ------------------------------------------------------ #
def claude_present():
    return bool(shutil.which("claude"))

def _plugin_state():
    """Best-effort snapshot of installed marketplaces + plugins from the claude CLI."""
    def lines(args):
        try:
            r = subprocess.run(["claude", *args], capture_output=True, text=True)
            return r.stdout if r.returncode == 0 else ""
        except Exception:
            return ""
    return lines(["plugin", "marketplace", "list"]) + "\n" + lines(["plugin", "list"])

def install_plugins(pins):
    say(BOLD("→ Marketplace + plugins (caveman, ponytail, wibx-skills)"))
    if not claude_present():
        skip("claude CLI not found — skipping plugin install "
             "(Claude Code only; Desktop/web use --desktop). Skills still sync below.")
        return
    state = "" if DRY else _plugin_state()
    mkt = pins["marketplace"]                 # e.g. Wibx-LABS/wibx-skills
    mkt_name = mkt.split("/")[-1]             # wibx-skills
    if mkt_name in state:
        run(["claude", "plugin", "marketplace", "update", mkt_name], check=False)
    else:
        run(["claude", "plugin", "marketplace", "add", mkt, "--scope", "user"], check=False)
    eco = pins["economy"]
    for pid in pins["plugins"]:
        if pid.startswith("caveman@") and eco.get("caveman_mode") == "off":
            continue
        if pid.startswith("ponytail@") and eco.get("ponytail_mode") == "off":
            continue
        if pid in state:
            run(["claude", "plugin", "update", pid], check=False)
        else:
            run(["claude", "plugin", "install", pid, "--scope", "user"], check=False)
    ok("plugins reconciled")

# ---- user-scope settings.json (MERGE, never clobber) --------------------- #
def settings_path():
    base = os.environ.get("CLAUDE_CONFIG_DIR") or str(Path.home() / ".claude")
    return Path(base) / "settings.json"

# rtk + graphify Claude hooks. Each is keyed by a stable marker so re-runs and
# machines that already have the hook do not duplicate it.
_HOOK_ENTRIES = [
    ("rtk hook claude", {
        "matcher": "Bash",
        "hooks": [{"type": "command",
                   "command": "command -v rtk >/dev/null 2>&1 && rtk hook claude || true",
                   "statusMessage": "rtk token-saver (wibx)"}]}),
    ("graphify query", {
        "matcher": "Bash",
        "hooks": [{"type": "command",
                   "command": ("CMD=$(python3 -c \"import json,sys; d=json.load(sys.stdin); "
                               "print(d.get('tool_input',d).get('command',''))\" 2>/dev/null || true); "
                               "case \"$CMD\" in *grep*|*rg\\ *|*find\\ *|*fd\\ *) "
                               "[ -f graphify-out/graph.json ] && echo "
                               "'{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\","
                               "\"additionalContext\":\"graphify-out/graph.json exists. Run "
                               "`graphify query \\\"<question>\\\"` before grepping raw files.\"}}' "
                               "|| true ;; esac")}]}),
]

def _marker_present(hooks_block, marker):
    for event in hooks_block.values():
        if not isinstance(event, list):
            continue
        for group in event:
            for h in (group.get("hooks") or []):
                if marker in (h.get("command") or ""):
                    return True
    return False

def reconcile_settings(data, pins):
    eco = pins["economy"]
    mkt = pins["marketplace"]
    mkt_name = mkt.split("/")[-1]

    # marketplaces (github source floats on default branch) — merge, keep others
    cur = data.get("extraKnownMarketplaces") or {}
    cur[mkt_name] = {"source": {"source": "github", "repo": mkt}}
    data["extraKnownMarketplaces"] = cur

    # enabledPlugins — merge, honour 'off' modes
    plugins = data.get("enabledPlugins") or {}
    for pid in pins["plugins"]:
        if pid.startswith("caveman@") and eco.get("caveman_mode") == "off":
            continue
        if pid.startswith("ponytail@") and eco.get("ponytail_mode") == "off":
            continue
        plugins[pid] = True
    data["enabledPlugins"] = plugins

    # economy env (drop the var when its mode is off)
    env = data.get("env") or {}
    for key, mode in (("CAVEMAN_DEFAULT_MODE", eco.get("caveman_mode")),
                      ("PONYTAIL_DEFAULT_MODE", eco.get("ponytail_mode"))):
        if mode and mode != "off":
            env[key] = mode
        else:
            env.pop(key, None)
    if env:
        data["env"] = env

    # hooks — MERGE (user scope is precious; never overwrite existing hooks)
    hooks = data.get("hooks") or {}
    pre = hooks.get("PreToolUse")
    if not isinstance(pre, list):
        pre = []
    for marker, entry in _HOOK_ENTRIES:
        if not _marker_present(hooks, marker):
            pre.append(entry)
    hooks["PreToolUse"] = pre
    data["hooks"] = hooks
    return data

def write_settings(pins):
    say(BOLD("→ User settings (~/.claude/settings.json)"))
    path = settings_path()
    if path.exists():
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            no(f"{path} exists but is not valid JSON — refusing to touch it. "
               "Fix the JSON and re-run.")
            return
    else:
        data = {}
    reconcile_settings(data, pins)
    if DRY:
        say(f"  {DIM('would write:')} {path}  (enabledPlugins + marketplace + env + hooks, merged)")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    ok(f"settings merged -> {path}")

# ---- skills catalog ------------------------------------------------------ #
def sync_skills():
    say(BOLD("→ Skills catalog (symlink sync)"))
    script = REPO / "scripts" / "skill_management.py"
    if not script.exists():
        no(f"missing {script}")
        return
    run([sys.executable, str(script), "--sync"], check=False)

# ---- desktop best-effort ------------------------------------------------- #
def desktop_notes(pins):
    pkgs = REPO / "packages"
    preamble = REPO / "install" / "desktop-preamble.md"
    say(BOLD("→ Claude Desktop (best-effort)"))
    say(f"  Desktop/web can't run hooks, the rtk/graphify binaries, or plugins.")
    say(f"  Skills:  upload {DIM(str(pkgs) + '/*.skill')} via Settings > Skills > Add Skill.")
    if preamble.exists():
        say(f"  Token economy: paste {DIM(str(preamble))} into your Desktop project's "
            f"custom instructions (text fallback for caveman + ponytail).")

# ---- check --------------------------------------------------------------- #
def do_check(pins):
    say(BOLD("wibx install — status"))
    (ok if rtk_present() else no)("rtk on PATH / ~/.local/bin")
    (ok if graphify_present() else no)("graphify importable")
    if claude_present():
        state = _plugin_state()
        for pid in pins["plugins"]:
            (ok if pid.split("@")[0] in state else no)(f"plugin {pid}")
    else:
        skip("claude CLI absent — plugin state unknown (Desktop/web)")
    sp = settings_path()
    if sp.exists():
        try:
            d = json.loads(sp.read_text(encoding="utf-8"))
            ok(f"{sp} valid; {len(d.get('enabledPlugins') or {})} enabled plugins")
        except json.JSONDecodeError:
            no(f"{sp} is not valid JSON")
    else:
        no(f"{sp} absent")
    skills = Path(os.environ.get("CLAUDE_CONFIG_DIR") or str(Path.home() / ".claude")) / "skills"
    n = len(list(skills.iterdir())) if skills.exists() else 0
    (ok if n else no)(f"{skills} — {n} skills linked")

# ---- main ---------------------------------------------------------------- #
def main():
    global DRY
    args = set(sys.argv[1:])
    DRY = "--dry-run" in args
    pins = load_pins()

    if "--check" in args:
        do_check(pins)
        return

    say(CYAN(BOLD("wibx-skills — core token economy pack + skills")) +
        (DIM("   [dry-run]") if DRY else ""))

    # "pack" = the token economy (host binaries + plugins + settings);
    # "skills" = the wibx skills catalog. Flags select which halves run.
    want_pack = "--skills-only" not in args
    want_skills = "--tools-only" not in args
    install_binaries = want_pack and "--no-tools" not in args

    if want_pack:
        if install_binaries:
            install_tools(pins)
        install_plugins(pins)
        write_settings(pins)
    if want_skills:
        sync_skills()
    if "--desktop" in args:
        desktop_notes(pins)

    say("")
    ok("done. New Claude Code sessions pick up the pack. "
       "Verify: python3 scripts/install.py --check")

if __name__ == "__main__":
    main()
