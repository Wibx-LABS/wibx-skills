---
name: security-audit
description: Use when asked to scan a cloned repo for threats, audit a project for malware or supply chain attacks, check if a repo is safe to run, scan for threats to the host machine, or run a full system security scan. Triggers on phrases like "scan this repo", "is this safe to run", "check for malware", "security audit", or "--system" scan requests.
---

# Security Audit

Protect the host machine from threats lurking in cloned repos or already on the system. Two modes: **repo scan** (default) and **system scan** (`--system`).

This is NOT a code quality audit. The threat model: code that attacks YOU — your credentials, your processes, your machine. Scan a repo **BEFORE running or installing it** — including code that runs on clone, editor-open, or install, not just what you launch explicitly.

## Modes

**Repo scan** — run from inside a cloned repo dir, or pass a path:
> "scan this repo", "audit this project", "is this safe?", `/security-audit`

**System scan** — full host inspection:
> "full system scan", "scan my machine", `/security-audit --system`

## Protocol

### Phase 1 — Mechanical Scan

Run scripts in order. Each script prints findings to stdout. Collect all output.

All scripts live in the same directory as this SKILL.md, under `scripts/`.

```
SKILL_DIR="$(dirname "$0")"   # or resolve from skill location
SCRIPTS="$SKILL_DIR/scripts"
```

**Step 0 — Preflight** (always):
```bash
bash "$SCRIPTS/00-preflight.sh"
```
Advisory only. Never abort on missing tools.

**Repo mode — Steps 1–8** (run from target dir or pass TARGET as $1):
```bash
TARGET="${1:-.}"
bash "$SCRIPTS/01-dependencies.sh"   "$TARGET"
bash "$SCRIPTS/02-build-scripts.sh"  "$TARGET"
bash "$SCRIPTS/03-code-patterns.sh"  "$TARGET"
bash "$SCRIPTS/04-binaries.sh"       "$TARGET"
bash "$SCRIPTS/05-cicd.sh"           "$TARGET"
bash "$SCRIPTS/07-secrets.sh"        "$TARGET"   # committed secrets / leaked creds (gitleaks + regex + tracked .env)
bash "$SCRIPTS/08-autorun.sh"        "$TARGET"   # code that runs on clone/open: git hooks, .envrc, .vscode, devcontainer
```
`07-secrets.sh` runs `gitleaks` over the full git history when available — on large
repos this is the slow step; run it in the background and stream the rest meanwhile.
Both steps degrade gracefully (regex fallback) when optional tools are absent.

**System mode — Step 6** (instead of 1–5, or in addition):
```bash
bash "$SCRIPTS/06-system.sh"
```

As each script runs, **stream findings live to the user** — do not buffer.

### Phase 2 — LLM Deep-Dive

After scripts complete, collect all unique file paths mentioned in findings.

For each flagged file (skip binaries and files >100KB):
1. Read the file content
2. Analyze for threats that patterns miss:
   - Obfuscated intent (logic that looks innocent but isn't)
   - Logic bombs (time-based, env-based, counter-based triggers)
   - Multi-step attack chains (benign parts that combine dangerously)
   - Subtle credential exfiltration (reading config files, env vars, then slow-leaking)
   - Social engineering in docs/READMEs directing user to run dangerous commands
   - Backdoors in utility/helper functions that look like normal code
3. Report additional findings with `[LLM-ANALYSIS]` prefix

### Phase 3 — Report

**Severity scale:** CRITICAL / HIGH / MEDIUM / LOW / INFO

Format each finding:
```
[SEVERITY] Short title
  Category: Dependencies | Build Scripts | Code Patterns | Binaries | CI/CD | Secrets | Auto-Execution | System | LLM Analysis
  File: path/to/file → specific location (line N, key name, etc.)
  Evidence: exact snippet or description
  Risk: what this enables against the host
  Action: what to do (quarantine / do not run npm install / investigate / etc.)
```

Save full report to:
- Repo mode: `security-audit-<repo-name>-<YYYY-MM-DD>.md` inside the scanned directory
- System mode: `/tmp/security-audit-system-<YYYY-MM-DD>.md`

End with a **summary block**:
```
SUMMARY
  CRITICAL: N
  HIGH: N
  MEDIUM: N
  LOW: N
  VERDICT: [SAFE TO RUN | REVIEW REQUIRED | DO NOT RUN | QUARANTINE]
```

VERDICT logic:
- Any CRITICAL → QUARANTINE
- Any HIGH → DO NOT RUN
- Only MEDIUM/LOW → REVIEW REQUIRED
- INFO only or no findings → SAFE TO RUN

## Skill Path Resolution

When the agent invokes scripts, find this skill's directory. The scripts are siblings of this SKILL.md. Use the absolute path. Example for Claude Code:

The skill is installed at `~/.claude/skills/security-audit/` (symlink to the wibx-skills workspace). Scripts are at `~/.claude/skills/security-audit/scripts/`.

Make scripts executable before running:
```bash
chmod +x ~/.claude/skills/security-audit/scripts/*.sh
```
