# `swarm` Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a manager-only `swarm` skill that partitions a text backlog into disjoint parallel fronts, scaffolds a shared `.swarm/` blackboard, and emits ready-to-launch prompts for N separate Claude Code instances — gated by a hard cost check so it can't be over-used.

**Architecture:** A prose skill (`SKILL.md` + two reference templates + evals). The skill body runs a fixed procedure: `doctor` cost-gate → partition → scaffold `.swarm/` → emit per-front prompts + manager cheat-sheet → manager loop. No code spawns workers; the human launches them. Verification is the skill-creator trigger-eval (proves explicit-only triggering) plus a procedure dry-run on fixture backlogs.

**Tech Stack:** Markdown skill (wibx-skills `skills/<name>/SKILL.md` convention); skill-creator `scripts.run_loop` for description optimization; `skill-management --sync` for global linking; git on branch `feat/swarm-skill`.

## Global Constraints

- Repo: `Wibx-LABS/wibx-skills`, branch `feat/swarm-skill` (never commit to `main`; PR per Labs convention).
- Skill location: `skills/swarm/` (flat convention, sibling to `refactor/`, `tot-h/`, etc.).
- `SKILL.md` body under ~500 lines; push templates/detail into `references/`.
- Mode is **manager-only**: the skill plans + emits, never spawns workers via the Agent tool.
- Blackboard is a local `.swarm/` dir at the target repo root, gitignored, shared across worktrees.
- Cost gate is mandatory and runs first: hard floor `< 4` independent fronts ⇒ refuse; forced explicit `y` confirm; explicit-trigger-only (must not fire on generic parallelism).
- Input is generic text (list / markdown / issue dump); no Notion or external-service dependency.
- Co-author trailer on every commit: `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.
- Spec of record: `docs/specs/2026-06-18-swarm-skill-design.md`.

---

## File Structure

```
skills/swarm/
├── SKILL.md                          # procedure: trigger discipline, doctor, partition, emit, manager loop
├── references/
│   ├── blackboard-protocol.md        # .swarm/ layout + claim→check→publish→append protocol + file templates
│   └── kickoff-template.md           # per-front kickoff prompt template + manager cheat-sheet
└── evals/
    ├── evals.json                    # 3 procedure test prompts + assertions
    └── trigger-eval.json             # 20 should/should-not-trigger queries for description optimization
```

Responsibilities:
- **SKILL.md** — the always-loaded procedure. Lean; points to the two references at the moments they're needed.
- **blackboard-protocol.md** — everything about the shared substrate and the anti-divergence protocol, loaded when scaffolding.
- **kickoff-template.md** — the exact text emitted per front + the manager's tracking cheat-sheet, loaded at the emit step.
- **evals/** — the verification harness.

---

### Task 1: Scaffold skill + frontmatter (trigger discipline lives here)

**Files:**
- Create: `skills/swarm/SKILL.md`

**Interfaces:**
- Produces: the skill `name: swarm` and the triggering `description` consumed by Task 7's trigger-eval.

- [ ] **Step 1: Write SKILL.md frontmatter + opening**

Create `skills/swarm/SKILL.md` starting with:

```markdown
---
name: swarm
description: Partition a backlog into disjoint parallel "fronts" and emit ready-to-launch prompts for several SEPARATE Claude Code instances, coordinated through a shared .swarm/ blackboard, with the invoking session acting as a no-code manager. Use ONLY when the user explicitly asks to fan out / swarm / split a backlog across many separate CC instances or agents — phrasings like "swarm this backlog", "fan out across N agents", "run 6 instances in parallel on these", "divide this into fronts for parallel agents". A hard cost gate refuses fewer than 4 truly independent fronts and forces an explicit cost confirmation, because each instance is a separately-billed full session and this is expensive when overused. Do NOT use for ordinary parallel subtasks inside one session (that is superpowers:dispatching-parallel-agents), and do NOT use for any work a single agent can do.
---

# Swarm

Turn a backlog into a collision-free, multi-instance attack plan — and act as the
manager who keeps the instances from diverging — without spending more than the job
is worth.

**This skill plans and emits. It never launches the workers.** You produce the
partition, the shared blackboard, and the paste-ready prompts; the human starts the
instances. That keeps the expensive axis (how many instances) under human control.

**Not** `superpowers:dispatching-parallel-agents`: that dispatches throwaway subagents
inside one session that share your context budget and need no shared state. Swarm
coordinates several full, separately-billed instances through an external file
blackboard, with git-worktree isolation and a manager role.

## Procedure (in order)

1. Run the **cost gate** (`doctor`). If it fails, stop.
2. **Partition** the backlog into disjoint fronts; flag feeders.
3. **Scaffold** the `.swarm/` blackboard (see `references/blackboard-protocol.md`).
4. **Emit** one kickoff prompt per front + a manager cheat-sheet (see
   `references/kickoff-template.md`).
5. Become the **manager**: track the blackboard, chase feeders, escalate. No code.
```

- [ ] **Step 2: Verify frontmatter parses and skill is discoverable**

Run:
```bash
cd /Users/caiosobrinho/LABS/wibx-skills
head -5 skills/swarm/SKILL.md
python3 -c "import yaml,sys; d=yaml.safe_load(open('skills/swarm/SKILL.md').read().split('---')[1]); print('name=',d['name']); assert d['name']=='swarm'; assert 'ONLY when' in d['description']"
```
Expected: prints `name= swarm` with no assertion error.

- [ ] **Step 3: Commit**

```bash
git add skills/swarm/SKILL.md
git commit -m "feat(swarm): scaffold skill + explicit-only trigger description

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: Cost gate / `doctor` section

**Files:**
- Modify: `skills/swarm/SKILL.md` (append the doctor section)

**Interfaces:**
- Consumes: the "Procedure" list from Task 1 (step 1 = cost gate).
- Produces: the `doctor` decision (`refuse` | `proceed`) that gates all later steps.

- [ ] **Step 1: Append the doctor section to SKILL.md**

```markdown
## 1. Cost gate (`doctor`) — run first, every time

Each instance you are about to recommend is a separately-billed full session. The whole
point of this gate is that fanning out is the expensive path, so it must be deliberate,
never reflexive. Work through it out loud before emitting anything:

1. **Detect candidate fronts** from the backlog (group items by the files/dirs/decisions
   they touch).
2. **Independence test:** for every pair of fronts, ask "do they edit the same package,
   dir, or file, or does one need the other's output mid-flight?" If yes, **merge them**.
   Repeat until fronts are pairwise disjoint. Shared state is the thing that makes parallel
   instances fight each other — eliminate it by collapsing, not by hoping.
3. **Hard floor:** if fewer than **4** disjoint fronts remain, **stop and refuse**. Tell the
   user this is below the swarm floor and recommend either doing it inline with one agent, or
   `superpowers:dispatching-parallel-agents` for independent subtasks within one session.
   Below ~4 fronts the fixed overhead of N cold instances (each re-deriving context) costs
   more than it saves.
4. **State the cost line** explicitly: `N instances ≈ N× a full session ⚠`.
5. **Require an explicit `y`.** Print the doctor summary and wait. No confirmation ⇒ emit
   nothing.

Print the summary in this shape:

​```
swarm doctor
  fronts found:        <N>
  independent?         <yes | collapsed M→N>
  below floor (<4)?    <no | YES → refusing>
  est. cost:           ~<N>× session  ⚠
  > confirm fan-out? [y/N]
​```
```

(Note: the triple-backtick above is shown fenced; in SKILL.md write it as a normal code block.)

- [ ] **Step 2: Dry-run verify — refusal path**

Read the section back and reason over a fixture: backlog = "fix login bug; rename a var; update README" → 3 items, not independent enough → fronts < 4.
Expected: the section's rule yields **refuse** with the inline-instead recommendation.

- [ ] **Step 3: Dry-run verify — proceed path**

Fixture: backlog with 8 items touching 8 distinct dirs.
Expected: doctor prints `fronts found: 8`, `below floor: no`, the `~8× session ⚠` line, and waits for `y`.

- [ ] **Step 4: Commit**

```bash
git add skills/swarm/SKILL.md
git commit -m "feat(swarm): cost gate / doctor (hard floor + forced confirm)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Partition rule + feeder ordering section

**Files:**
- Modify: `skills/swarm/SKILL.md` (append partition section)

**Interfaces:**
- Consumes: the disjoint fronts produced by the doctor (Task 2).
- Produces: a per-front record `{name, owned_paths[], branch, is_feeder, depends_on[]}` consumed by the scaffold (Task 4) and emit (Task 5) steps.

- [ ] **Step 1: Append the partition section**

```markdown
## 2. Partition

A front **owns a set of paths no other front touches** — that disjoint ownership is what
makes parallel instances collision-free. For each front, record:

- **name** — short, area-based (e.g. `gateway-authz`, `radar-fetch`).
- **owned_paths** — the dirs/files only this front edits. If two drafts overlap, you
  didn't finish the independence test — go back and merge.
- **branch** — `feat/<name>` (code) or `docs/<name>` (docs-only fronts).
- **is_feeder** — true if another front needs this front's decision or interface before it
  can finish (e.g. an access-control design, a data-shape contract, a key decision).
- **depends_on** — the feeder fronts this one consumes.

**Feeders ship first.** A downstream front builds behind a stubbed interface until the
feeder's contract lands on the blackboard, so nobody blocks waiting. Order the emitted
prompts feeders-first and say so in the manager cheat-sheet.
```

- [ ] **Step 2: Dry-run verify**

Fixture: 8-front backlog where one front is "decide the auth model" that two others consume.
Expected: that front is marked `is_feeder: true`; the two consumers list it in `depends_on`; emit order puts it first.

- [ ] **Step 3: Commit**

```bash
git add skills/swarm/SKILL.md
git commit -m "feat(swarm): partition rule + feeder-first ordering

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: Blackboard protocol reference + scaffold step

**Files:**
- Create: `skills/swarm/references/blackboard-protocol.md`
- Modify: `skills/swarm/SKILL.md` (append scaffold step that points to the reference)

**Interfaces:**
- Consumes: the per-front records from Task 3.
- Produces: the `.swarm/` directory layout + the worker protocol that Task 5's kickoff prompt embeds by reference.

- [ ] **Step 1: Create references/blackboard-protocol.md**

```markdown
# `.swarm/` blackboard protocol

The blackboard is the shared substrate that keeps separate instances from diverging.
It lives at the **target repo root**, is **gitignored**, and is **shared across all
worktrees**: each instance reads and writes it via the *absolute main-repo path*, which
is exactly how a git worktree writes back into the main tree. (Heads-up: an absolute
main-repo path from inside a worktree lands in the MAIN tree, not the worktree checkout —
here that's the feature, not a bug.)

## Layout

​```
.swarm/
  blackboard.md   # one row per front: state + ownership
  contracts/      # one file per published interface/decision others depend on
  log.md          # append-only event log — the divergence guard
​```

## blackboard.md template

​```markdown
# Swarm blackboard — <backlog title>
updated: <iso8601 by manager>

| front | owner | branch | owned_paths | status | blocked_reason |
|-------|-------|--------|-------------|--------|----------------|
| gateway-authz | (unclaimed) | feat/gateway-authz | backend/gateway/** | todo | |
| radar-fetch   | (unclaimed) | feat/radar-fetch   | engine/.../m4 + search | todo | |

status ∈ {todo, claimed, in_progress, review, done, blocked}
​```

## log.md template (append-only)

​```
<iso8601> <front> CLAIM owner=<instance-id>
<iso8601> <front> CONTRACT published contracts/<file>
<iso8601> <front> STATUS in_progress→review pr=<url>
<iso8601> <front> BLOCKED reason="<why>"
​```

## contracts/<front>.md template

​```markdown
# Contract: <front>
status: draft | stable
interface:
  <the exact signatures / data shape / decision downstream fronts must build against>
notes:
  <anything a consumer needs; link the PR once it lands>
​```

## Worker protocol (every instance follows this)

1. **On wake:** read `blackboard.md` + `log.md` (full picture before acting).
2. **Claim:** set your row's `owner` + `status: claimed` and append a `CLAIM` line. If the
   row is already owned by someone else, stop — you grabbed the wrong front.
3. **Check before shared edges:** if your front `depends_on` a feeder, read its
   `contracts/<feeder>.md`. Missing or `draft`? Build behind a local stub and keep going;
   don't block.
4. **Publish early:** the moment your own interface is fixed, write `contracts/<you>.md`
   (`status: stable`) and append a `CONTRACT` line — downstream fronts are waiting on it.
5. **Append every transition** to `log.md`. The manager reconciles only from the log, so an
   unlogged change is an invisible change.

The manager **reads** the blackboard and reconciles; it never edits another front's row or
code.
```

- [ ] **Step 2: Append the scaffold step to SKILL.md**

```markdown
## 3. Scaffold the blackboard

Create `.swarm/` at the target repo root and add `.swarm/` to `.gitignore`. Write
`blackboard.md` with one row per front (status `todo`, owner `(unclaimed)`), create an
empty `contracts/`, and start `log.md`. Use the exact templates and the worker protocol in
`references/blackboard-protocol.md` — that protocol is what each instance follows to avoid
divergence, and it is embedded by reference into every kickoff prompt.
```

- [ ] **Step 3: Verify reference is well-formed and linked**

Run:
```bash
cd /Users/caiosobrinho/LABS/wibx-skills
test -f skills/swarm/references/blackboard-protocol.md && echo "ref exists"
grep -q "references/blackboard-protocol.md" skills/swarm/SKILL.md && echo "linked from SKILL.md"
grep -q "append-only" skills/swarm/references/blackboard-protocol.md && echo "has log guard"
```
Expected: prints all three confirmations.

- [ ] **Step 4: Commit**

```bash
git add skills/swarm/references/blackboard-protocol.md skills/swarm/SKILL.md
git commit -m "feat(swarm): .swarm/ blackboard protocol + scaffold step

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5: Kickoff template reference + emit step + manager loop

**Files:**
- Create: `skills/swarm/references/kickoff-template.md`
- Modify: `skills/swarm/SKILL.md` (append emit step + manager-loop section)

**Interfaces:**
- Consumes: per-front records (Task 3) + blackboard protocol (Task 4).
- Produces: the per-front prompt text and manager cheat-sheet (final user-facing output).

- [ ] **Step 1: Create references/kickoff-template.md**

```markdown
# Kickoff prompt template + manager cheat-sheet

## Per-front kickoff prompt (fill the <…> and emit one per front)

​```
You are worker instance "<front-name>" in a swarm. Your scope is ONLY this front.

Owned paths (never edit outside these): <owned_paths>
Branch: <branch>
Blackboard (shared, absolute path): <repo-root>/.swarm/

Procedure:
1. Read <repo-root>/.swarm/blackboard.md and log.md.
2. Claim your row (owner + status=claimed, append a CLAIM line to log.md). If already
   owned by someone else, STOP and report.
3. Create your worktree with superpowers:using-git-worktrees on branch <branch>.
4. <feeders only> Before building shared edges, read contracts/<dep>.md for each of:
   <depends_on>. If missing/draft, build behind a stub — do not block.
5. Per item: superpowers brainstorming → writing-plans → (code) test-driven-development →
   verification-before-completion. Publish your own contracts/<front-name>.md early.
6. Validate with this repo's gates before each PR: <gates>. Append every status change to
   log.md. PRs in <language>. Never commit to main; never merge.

Your items:
<the backlog items for this front, verbatim>
​```

## Manager cheat-sheet (emit once)

​```
You are the swarm MANAGER. You do not write code or edit any front's files.

Emit order (feeders first): <ordered front list>
Loop:
- Read .swarm/blackboard.md + log.md; print a tally: todo / claimed / in_progress /
  review / done / blocked, per front.
- For each unmet dependency (a front waiting on a feeder's contract), ping the feeder.
- Escalate to the human: blockers, contract disputes, and PRs ready for review/merge.
- Reconcile blackboard rows from log.md. Do not edit other fronts' rows' content beyond
  status reconciliation.
Cost reminder: <N> instances are running ≈ <N>× a session. Stop idle instances.
​```
```

- [ ] **Step 2: Append emit step + manager loop to SKILL.md**

```markdown
## 4. Emit

Using `references/kickoff-template.md`, output one filled kickoff prompt per front
(feeders first) and one manager cheat-sheet. Fill `<gates>` from the target repo's
validation commands (build/test/lint) and `<language>` from its PR convention. Hand these
to the human to launch — you do not start them.

## 5. Manage

Adopt the manager cheat-sheet yourself. Read the blackboard, tally status, chase unmet
feeder contracts, escalate blockers and review-ready PRs to the human, and reconcile rows
from `log.md`. Never write code, never edit another front's files, never merge. Remind the
human of the running cost so idle instances get stopped.
```

- [ ] **Step 3: Verify SKILL.md length + all sections present**

Run:
```bash
cd /Users/caiosobrinho/LABS/wibx-skills
wc -l skills/swarm/SKILL.md   # expect well under 500
for s in "Cost gate" "Partition" "Scaffold the blackboard" "Emit" "Manage"; do grep -q "$s" skills/swarm/SKILL.md && echo "ok: $s"; done
```
Expected: line count < 500 and five `ok:` lines.

- [ ] **Step 4: Commit**

```bash
git add skills/swarm/references/kickoff-template.md skills/swarm/SKILL.md
git commit -m "feat(swarm): kickoff template + emit step + manager loop

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 6: Evals — procedure tests + trigger queries

**Files:**
- Create: `skills/swarm/evals/evals.json`
- Create: `skills/swarm/evals/trigger-eval.json`

**Interfaces:**
- Consumes: the finished skill (Tasks 1–5).
- Produces: the eval sets Task 7 runs.

- [ ] **Step 1: Create evals/evals.json (procedure behavior)**

```json
{
  "skill_name": "swarm",
  "evals": [
    {
      "id": 1,
      "prompt": "I've got this backlog of 9 issues, each in a totally different service (auth-svc, billing-svc, search-svc, notify-svc, ...). I want to fan out 9 separate Claude Code instances to clear them in parallel. Set it up.",
      "expected_output": "Runs doctor, confirms 9 disjoint fronts >= floor, prints N× cost line, scaffolds .swarm/, emits 9 kickoff prompts + manager cheat-sheet, becomes manager. Does NOT spawn agents itself.",
      "assertions": [
        {"text": "Runs the doctor cost gate before emitting anything", "passed": null, "evidence": ""},
        {"text": "Prints an explicit N× session cost line and asks for confirmation", "passed": null, "evidence": ""},
        {"text": "Creates a .swarm/ scaffold (blackboard.md, contracts/, log.md)", "passed": null, "evidence": ""},
        {"text": "Emits one kickoff prompt per front plus a manager cheat-sheet", "passed": null, "evidence": ""},
        {"text": "Does not call the Agent tool to launch workers itself", "passed": null, "evidence": ""}
      ],
      "files": []
    },
    {
      "id": 2,
      "prompt": "Can you swarm these three things for me: fix the flaky login test, bump the eslint version, and fix a typo in the footer?",
      "expected_output": "doctor refuses: fewer than 4 independent fronts; recommends doing it inline with one agent (or dispatching-parallel-agents).",
      "assertions": [
        {"text": "Refuses to fan out because fronts < 4 floor", "passed": null, "evidence": ""},
        {"text": "Recommends inline single-agent or dispatching-parallel-agents instead", "passed": null, "evidence": ""},
        {"text": "Does not scaffold .swarm/ or emit kickoff prompts", "passed": null, "evidence": ""}
      ],
      "files": []
    },
    {
      "id": 3,
      "prompt": "Swarm this 6-item backlog, but two of the items both heavily edit the same payments module.",
      "expected_output": "Independence test collapses the two overlapping items into one front; re-checks the floor on the reduced count; only proceeds if >= 4 disjoint fronts remain.",
      "assertions": [
        {"text": "Merges the two payments-module items into a single front", "passed": null, "evidence": ""},
        {"text": "Re-evaluates the floor against the reduced disjoint-front count", "passed": null, "evidence": ""}
      ],
      "files": []
    }
  ]
}
```

- [ ] **Step 2: Create evals/trigger-eval.json (20 queries; the anti-overuse test)**

```json
[
  {"query": "swarm this backlog — i have 8 github issues each in its own microservice and want 8 separate claude instances chewing through them at once", "should_trigger": true},
  {"query": "can you fan this out across like 6 agents? the work splits cleanly: gateway, billing, search, notifications, auth, and the cron worker", "should_trigger": true},
  {"query": "i want to run five separate cc instances in parallel on these five independent refactors, with something keeping them from stepping on each other", "should_trigger": true},
  {"query": "divide this roadmap into fronts for parallel agents and give me the prompts to launch each one, plus a way to track them", "should_trigger": true},
  {"query": "we need to clear this whole infra+backend backlog fast — set up a multi-instance attack with one front per subsystem and a shared coordination file", "should_trigger": true},
  {"query": "split these 10 tickets across separate claude code sessions so a bunch of us can launch them tonight, and act as the coordinator", "should_trigger": true},
  {"query": "i keep over-spawning agents and blowing my budget — i have 7 unrelated modules to update, do the proper fan-out plan with a cost check first", "should_trigger": true},
  {"query": "turn this list of independent features into a worktree-per-front swarm with a blackboard the instances sync through", "should_trigger": true},
  {"query": "there are 4 totally separate bugs in 4 separate packages; orchestrate parallel instances and manage the progress", "should_trigger": true},
  {"query": "set up the manager+workers thing where you carve the backlog into disjoint fronts and emit launch prompts for each", "should_trigger": true},
  {"query": "this login test is flaky and intermittent, can you debug why it fails about 1 in 5 runs", "should_trigger": false},
  {"query": "i have three failing test files from a refactor, fix them in parallel subagents within this session", "should_trigger": false},
  {"query": "run these two scripts in parallel and tell me which finishes first", "should_trigger": false},
  {"query": "what's the best way to parallelize a slow for-loop in my python data pipeline", "should_trigger": false},
  {"query": "create a worktree for me so i can work on the payments refactor in isolation", "should_trigger": false},
  {"query": "i have a big backlog of 20 tickets, help me prioritize them into P0/P1/P2 for next sprint", "should_trigger": false},
  {"query": "split this 2000-line file into smaller modules with one responsibility each", "should_trigger": false},
  {"query": "summarize all the open issues in this repo and group them by component", "should_trigger": false},
  {"query": "can you fan out the heat better in this css grid layout, the cards are bunched on the left", "should_trigger": false},
  {"query": "two of my services need the same change — just make the edit in both, it's tiny", "should_trigger": false}
]
```

- [ ] **Step 3: Validate JSON**

Run:
```bash
cd /Users/caiosobrinho/LABS/wibx-skills
python3 -c "import json; json.load(open('skills/swarm/evals/evals.json')); t=json.load(open('skills/swarm/evals/trigger-eval.json')); print('evals ok'); assert len(t)==20; assert sum(q['should_trigger'] for q in t) in range(8,13); print('trigger set ok', sum(q['should_trigger'] for q in t),'positive')"
```
Expected: `evals ok` and `trigger set ok 10 positive` (8–12 acceptable).

- [ ] **Step 4: Commit**

```bash
git add skills/swarm/evals/
git commit -m "feat(swarm): procedure evals + 20-query trigger eval set

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 7: Optimize triggering, dry-run, sync, finalize

**Files:**
- Modify: `skills/swarm/SKILL.md` (apply optimized description)

**Interfaces:**
- Consumes: everything from Tasks 1–6.
- Produces: the finished, synced skill.

- [ ] **Step 1: Run the description-optimization loop (the explicit-only-trigger guarantee)**

From the skill-creator directory, run in the background:
```bash
python -m scripts.run_loop \
  --eval-set /Users/caiosobrinho/LABS/wibx-skills/skills/swarm/evals/trigger-eval.json \
  --skill-path /Users/caiosobrinho/LABS/wibx-skills/skills/swarm \
  --model claude-opus-4-8 \
  --max-iterations 5 \
  --verbose
```
Expected: completes and reports a `best_description` selected on the held-out test split. The whole point is the should-NOT-trigger near-misses (flaky test, in-session subagents, "parallelize a loop", "fan out the heat in CSS") stay below threshold while the explicit swarm phrasings fire.

- [ ] **Step 2: Apply `best_description`**

Replace the `description:` field in `skills/swarm/SKILL.md` frontmatter with `best_description`. Show the user before/after and the train/test scores.

- [ ] **Step 3: Procedure dry-run on a fixture (qualitative acceptance)**

In a throwaway temp git repo, invoke the skill with eval prompt #1 and confirm it: runs doctor, prints the cost line, scaffolds `.swarm/` with the three files, emits 9 kickoff prompts + cheat-sheet, and never calls the Agent tool. Then invoke with eval prompt #2 and confirm it refuses.
Expected: both behaviors match `evals/evals.json`.

- [ ] **Step 4: Sync the skill globally**

```bash
cd /Users/caiosobrinho/LABS/wibx-skills
python3 scripts/skill_management.py --sync swarm
```
Expected: prints a symlink confirmation for `swarm`.

- [ ] **Step 5: Commit**

```bash
git add skills/swarm/SKILL.md
git commit -m "feat(swarm): apply optimized trigger description + sync

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

- [ ] **Step 6: Open PR**

```bash
cd /Users/caiosobrinho/LABS/wibx-skills
git push -u origin feat/swarm-skill
gh pr create --title "feat(swarm): manager-only fan-out skill" --body "$(cat <<'EOF'
## O quê
Nova skill `swarm`: particiona um backlog em frentes disjuntas, monta um blackboard
`.swarm/` compartilhado e emite prompts prontos para lançar N instâncias Claude Code
separadas, com a sessão atual atuando como manager (sem código).

## Por quê
Captura o padrão do mutirão de backlog, mas com trava de custo: só faneia com ≥4 frentes
independentes + confirmação explícita; dispara só em pedido explícito de swarm/fan-out.
Complementa `dispatching-parallel-agents` (subagents in-session), não substitui.

## Verificação
- trigger-eval (20 queries) via skill-creator run_loop
- dry-run da procedure (doctor recusa <4; emite frentes+cheat-sheet em backlog válido)

Spec: docs/specs/2026-06-18-swarm-skill-design.md

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```
Expected: PR URL printed. Labs reviews/merges.

---

## Self-Review

**Spec coverage:**
- §1 trigger discipline → Task 1 description + Task 7 trigger-eval ✓
- §2 cost gate/doctor → Task 2 + eval #2/#3 ✓
- §3 `.swarm/` blackboard + divergence guard → Task 4 ✓
- §4 partition + feeders → Task 3 ✓
- §5 emitted artifacts → Task 5 ✓
- §6 manager loop → Task 5 (Manage) ✓
- §7 testing → Task 6 + Task 7 ✓
- Open items (line formats; doctor helper script) → resolved prose-first in Task 4 templates; no helper script (stays zero-install per tooling-four-laws) ✓

**Placeholder scan:** all content blocks are literal (frontmatter, doctor text, templates, both eval JSONs). The `<…>` tokens inside the kickoff/manager templates are intentional fill-slots the skill populates at emit time, not plan placeholders.

**Type/name consistency:** front record fields (`name`, `owned_paths`, `branch`, `is_feeder`, `depends_on`) are defined in Task 3 and reused verbatim in Tasks 4–5; `.swarm/` files (`blackboard.md`, `contracts/`, `log.md`) named identically across Tasks 4–6; skill name `swarm` consistent throughout.
