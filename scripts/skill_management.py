#!/usr/bin/env python3
import os
import sys
import time
import threading
from pathlib import Path

# Paths
# WORKSPACE_SKILLS derives from this script's location so the repo stays
# clone-portable (no hardcoded user path). Destinations live under the
# current user's HOME, so a teammate cloning this repo links into their
# own agent directories.
WORKSPACE_SKILLS = Path(__file__).resolve().parents[1] / "skills"
HOME = Path.home()
GLOBAL_WORKFLOWS = HOME / ".gemini/config/global_workflows"
GLOBAL_SKILLS_CLI = HOME / ".gemini/antigravity-cli/skills"
GLOBAL_SKILLS_CONFIG = HOME / ".gemini/config/skills"
CLAUDE_SKILLS = HOME / ".claude/skills"

SYNC_DESTINATIONS = [
    ("Antigravity IDE (Workflows)", GLOBAL_WORKFLOWS, "file"),
    ("Antigravity CLI (Skills)", GLOBAL_SKILLS_CLI, "dir"),
    ("Antigravity IDE (Skills)", GLOBAL_SKILLS_CONFIG, "dir"),
    ("Claude Code (Skills)", CLAUDE_SKILLS, "dir")
]

# ANSI Color & Style Codes
BLUE = "\033[1;34m"
CYAN = "\033[1;36m"
GREEN = "\033[1;32m"
YELLOW = "\033[1;33m"
RED = "\033[1;31m"
MAGENTA = "\033[1;35m"
BOLD = "\033[1m"
DIM = "\033[2m"
RESET = "\033[0m"

ASCII_BANNER = f"""{MAGENTA}  __        _____ ______  __ {RESET}
{MAGENTA}  \\ \\      / /_ _| __ ) \\/ /{RESET}
{CYAN}   \\ \\ /\\ / / | ||  _ \\\\  / {RESET}
{CYAN}    \\ V  V /  | || |_) /  \\ {RESET}
{BLUE}     \\_/\\_/  |___|____/_/\\_\\{RESET}"""

class Spinner:
    def __init__(self, message="Loading...", delay=0.1):
        self.message = message
        self.delay = delay
        self.spinner_chars = ['|', '/', '-', '\\']
        self.stop_running = threading.Event()
        self.thread = None

    def _spin(self):
        idx = 0
        colors = [CYAN, BLUE, MAGENTA, YELLOW]
        while not self.stop_running.is_set():
            color = colors[idx % len(colors)]
            sys.stdout.write(f"\r{color}{self.spinner_chars[idx % len(self.spinner_chars)]}{RESET} {DIM}{self.message}{RESET}")
            sys.stdout.flush()
            time.sleep(self.delay)
            idx += 1
        # Clear line on exit
        sys.stdout.write("\r\033[K")
        sys.stdout.flush()

    def __enter__(self):
        self.thread = threading.Thread(target=self._spin, daemon=True)
        self.thread.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop_running.set()
        if self.thread:
            self.thread.join()

def parse_frontmatter(skill_md_path):
    """
    Extracts key-value pairs from YAML frontmatter in a SKILL.md file.
    Supports multi-line folded/block scalars.
    """
    if not skill_md_path.exists():
        return None
    try:
        with open(skill_md_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        if not lines or not lines[0].strip() == '---':
            return None

        yaml_lines = []
        for line in lines[1:]:
            if line.strip() == '---':
                break
            yaml_lines.append(line)

        frontmatter = {}
        current_key = None
        multiline_value = []
        multiline_indent = None

        for line in yaml_lines:
            # Check if we are currently gathering lines for a multiline key
            if current_key is not None and (multiline_value or line.strip()):
                stripped = line.lstrip()
                indent = len(line) - len(stripped)

                if not line.strip():
                    multiline_value.append("")
                    continue

                if multiline_indent is None:
                    multiline_indent = indent

                if indent >= multiline_indent:
                    multiline_value.append(line[multiline_indent:].rstrip('\r\n'))
                    continue
                else:
                    frontmatter[current_key] = "\n".join(multiline_value).strip()
                    current_key = None
                    multiline_value = []
                    multiline_indent = None

            if ':' in line:
                key, val = line.split(':', 1)
                key = key.strip()
                val = val.strip()
                if val in ('|', '>', '|-', '>-', '|+', '>+'):
                    current_key = key
                    multiline_value = []
                    multiline_indent = None
                else:
                    frontmatter[key] = val

        if current_key is not None and multiline_value:
            frontmatter[current_key] = "\n".join(multiline_value).strip()

        return frontmatter
    except Exception:
        return None

def show_help():
    print(ASCII_BANNER)
    print(f"\n{BOLD}{CYAN}:: {YELLOW}WIBX Skills Manager {CYAN}::{RESET}")
    print(f"{DIM}-----------------------------------------------------------------------------{RESET}")
    help_text = f"""{BOLD}Usage:{RESET}
  skill-management {BLUE}--list{RESET}            List all skills currently in the workspace.
  skill-management {BLUE}--sync{RESET}            Synchronize all workspace skills to global workflows.
  skill-management {BLUE}--sync <name>{RESET}     Synchronize only the specified skill.
  skill-management {BLUE}<name>{RESET}            Check the description of a specific skill.
  skill-management {BLUE}--help{RESET}            Show this help message.
"""
    print(help_text)

def list_skills():
    print(f"\n{BOLD}Available Skills in Workspace:{RESET}")
    print(f"{DIM}-----------------------------------------------------------------------------{RESET}")

    if not WORKSPACE_SKILLS.exists():
        print(f"[Error] Workspace skills directory not found at: {WORKSPACE_SKILLS}")
        sys.exit(1)

    found = False
    for skill_dir in sorted(WORKSPACE_SKILLS.iterdir()):
        if not skill_dir.is_dir():
            continue

        skill_md = skill_dir / "SKILL.md"
        if not skill_md.exists():
            continue

        found = True
        skill_name = skill_dir.name
        fm = parse_frontmatter(skill_md)
        description = fm.get("description", "No description provided.") if fm else "No description provided."

        print(f"  * {BOLD}{BLUE}{skill_name}{RESET}")

        desc_lines = description.split('\n')
        for line in desc_lines:
            print(f"    {DIM}{line}{RESET}")
        print(f"{DIM}-----------------------------------------------------------------------------{RESET}")

    if not found:
        print(f"  [Info] No skills found in workspace skills directory.")

def show_skill_description(skill_name):
    skill_dir = WORKSPACE_SKILLS / skill_name
    skill_md = skill_dir / "SKILL.md"

    if not skill_md.exists():
        print(f"[Error] Skill '{skill_name}' not found at: {skill_md}")
        sys.exit(1)

    fm = parse_frontmatter(skill_md)
    if fm and "description" in fm:
        print(f"\n* {BOLD}{CYAN}{skill_name}{RESET}")
        print(f"{DIM}--- Description -------------------------------------------------------------{RESET}")
        desc_lines = fm["description"].split('\n')
        for line in desc_lines:
            print(f"  {BLUE}|{RESET} {line}")
        print(f"{DIM}-----------------------------------------------------------------------------{RESET}\n")
    else:
        print(f"[Warning] No frontmatter description found in {skill_md.name}")

def sync_single_skill(skill_name):
    print(f"--> {BOLD}Syncing skill '{skill_name}'...{RESET}")

    skill_dir = WORKSPACE_SKILLS / skill_name
    skill_md = skill_dir / "SKILL.md"

    if not skill_md.exists():
        print(f"{RED}[Error]{RESET} Skill '{skill_name}' not found at: {skill_md}", file=sys.stderr)
        sys.exit(1)

    for name, dest, target_type in SYNC_DESTINATIONS:
        if not dest.exists():
            print(f"{YELLOW}[Dir]{RESET} Creating {name} directory: {dest}")
            dest.mkdir(parents=True, exist_ok=True)

        if target_type == "file":
            source_path = skill_md
            target_link = dest / f"{skill_name}.md"
        else:
            source_path = skill_dir
            target_link = dest / skill_name

        result_msg = None
        result_err = None

        with Spinner(f"Syncing '{skill_name}' to {name}..."):
            time.sleep(0.15)
            try:
                if target_link.exists() or target_link.is_symlink():
                    if target_link.is_symlink():
                        current_target = Path(os.readlink(target_link)).resolve()
                        if current_target == source_path.resolve():
                            result_msg = f"{GREEN}[OK]{RESET} Link matches: {target_link.name} -> {source_path.name} in {name}"
                        else:
                            target_link.unlink()
                    else:
                        if target_link.is_dir() and not target_link.is_symlink():
                            import shutil
                            shutil.rmtree(target_link)
                        else:
                            target_link.unlink()

                if result_msg is None:
                    os.symlink(source_path, target_link)
                    display_source = f"skills/{skill_name}/SKILL.md" if target_type == "file" else f"skills/{skill_name}"
                    result_msg = f"{GREEN}[Link]{RESET} Created: {target_link.name} -> {display_source} in {name}"
            except Exception as e:
                result_err = f"{RED}[Error]{RESET} Failed to link to {name}: {e}"

        if result_err:
            print(result_err, file=sys.stderr)
        else:
            print(result_msg)

    print(f"{GREEN}[OK] Synchronized '{skill_name}' successfully across all targets!{RESET}")

def sync_all_skills():
    print(f"--> {BOLD}Running WIBX Skills Synchronizer...{RESET}")

    if not WORKSPACE_SKILLS.exists():
        print(f"{RED}[Error]{RESET} Workspace skills directory not found at: {WORKSPACE_SKILLS}", file=sys.stderr)
        sys.exit(1)

    active_skills_files = set(f"{skill_dir.name}.md" for skill_dir in WORKSPACE_SKILLS.iterdir() if skill_dir.is_dir() and (skill_dir / "SKILL.md").exists())
    active_skills_dirs = set(skill_dir.name for skill_dir in WORKSPACE_SKILLS.iterdir() if skill_dir.is_dir() and (skill_dir / "SKILL.md").exists())

    for name, dest, target_type in SYNC_DESTINATIONS:
        print(f"\n{YELLOW}[Target]{RESET} {BOLD}Syncing to {name}...{RESET}")
        if not dest.exists():
            print(f"{YELLOW}[Dir]{RESET} Creating {name} directory: {dest}")
            dest.mkdir(parents=True, exist_ok=True)

        for skill_dir in sorted(WORKSPACE_SKILLS.iterdir()):
            if not skill_dir.is_dir():
                continue

            skill_md = skill_dir / "SKILL.md"
            if not skill_md.exists():
                continue

            skill_name = skill_dir.name

            if target_type == "file":
                source_path = skill_md
                target_link = dest / f"{skill_name}.md"
            else:
                source_path = skill_dir
                target_link = dest / skill_name

            result_msg = None
            result_err = None

            with Spinner(f"Syncing '{skill_name}'..."):
                time.sleep(0.15)
                try:
                    if target_link.exists() or target_link.is_symlink():
                        if target_link.is_symlink():
                            current_target = Path(os.readlink(target_link)).resolve()
                            if current_target == source_path.resolve():
                                result_msg = f"{GREEN}[OK]{RESET} Link matches: {target_link.name} -> {source_path.name}"
                            else:
                                target_link.unlink()
                        else:
                            if target_link.is_dir() and not target_link.is_symlink():
                                import shutil
                                shutil.rmtree(target_link)
                            else:
                                target_link.unlink()

                    if result_msg is None:
                        os.symlink(source_path, target_link)
                        display_source = f"skills/{skill_name}/SKILL.md" if target_type == "file" else f"skills/{skill_name}"
                        result_msg = f"{GREEN}[Link]{RESET} Created: {target_link.name} -> {display_source}"
                except Exception as e:
                    result_err = f"{RED}[Error]{RESET} Failed to link {skill_name}: {e}"

            if result_err:
                print(result_err, file=sys.stderr)
            else:
                print(result_msg)

        active_links = active_skills_files if target_type == "file" else active_skills_dirs
        stale_links = []

        with Spinner("Cleaning up stale links..."):
            time.sleep(0.2)
            try:
                for file_path in dest.iterdir():
                    is_stale = False
                    if target_type == "file" and file_path.name.endswith(".md"):
                        is_stale = file_path.name not in active_links
                    elif target_type == "dir":
                        is_stale = file_path.name not in active_links

                    if is_stale and file_path.is_symlink():
                        target_path = Path(os.readlink(file_path)).resolve()
                        if WORKSPACE_SKILLS.resolve() in target_path.parents or WORKSPACE_SKILLS.resolve() == target_path.resolve():
                            file_path.unlink()
                            stale_links.append(file_path.name)
            except Exception as e:
                print(f"{YELLOW}[Warning]{RESET} Failed checking symlinks during cleanup in {name}: {e}", file=sys.stderr)

        if stale_links:
            for link in stale_links:
                print(f"{YELLOW}[Clean]{RESET} Removed stale symlink: {link} in {name}")
        else:
            print(f"{GREEN}[Clean]{RESET} No stale links to clean up.")

    print(f"\n{GREEN}[OK] Done synchronization! All skills up-to-date across all targets.{RESET}")

def main():
    args = sys.argv[1:]

    if not args:
        show_help()
        sys.exit(0)

    cmd = args[0]

    if cmd == "--help" or cmd == "-h":
        show_help()
    elif cmd == "--list":
        list_skills()
    elif cmd == "--sync":
        if len(args) > 1:
            skill_name = args[1]
            sync_single_skill(skill_name)
        else:
            sync_all_skills()
    else:
        if cmd.startswith("-"):
            print(f"[Error] Unknown option: {cmd}")
            show_help()
            sys.exit(1)
        show_skill_description(cmd)

if __name__ == "__main__":
    main()
