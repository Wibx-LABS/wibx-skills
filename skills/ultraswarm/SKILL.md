---
name: ultraswarm
description: Extreme variant of the swarm skill. Fan out a backlog across several SEPARATE Claude Code instances with maximum rigor AND token discipline. Plans the partition first (plan mode or superpowers:writing-plans), attaches a matched skill stack plus caveman and RTK to every front for token control, routes each front to a best-fit model and effort, locks each worker with the native /goal command, and gates every front plus the merged result with /code-review ultra. Optional read-only live dashboard shows per-front status and token usage. Use ONLY when the user explicitly asks for an extreme, ultra, or maximum-rigor fan-out — phrasings like "ultraswarm this backlog", "extreme swarm these fronts", "swarm this hard and nail it". Inherits swarm's hard cost gate — refuses fewer than 4 disjoint fronts and forces explicit confirmation, since each instance is a separately-billed session. For an ordinary fan-out use swarm; for parallel subtasks inside one session use superpowers:dispatching-parallel-agents.
---

# Ultraswarm

The extreme fan-out: everything `swarm` does, plus a plan-first gate, an explicit
`/goal` lock per front, mandatory caveman + RTK token discipline, best-fit model/effort
routing, a matched per-front skill stack, `/code-review ultra` on every front and on the
merged result, and an optional live dashboard. More rigorous *and* more token-efficient
than base swarm — never cheaper, but never wasteful.

**This is still a plan-and-emit manager skill.** You (this session) plan, scaffold, emit
paste-ready worker prompts, and manage — you never write front code or merge. The human
starts the instances (or the opt-in launcher does, only after the cost gate `y`).

**Reuses the swarm engine, does not fork it.** The `.swarm/` blackboard, the git-worktree
isolation, `swarm/scripts/swarm-launch.sh`, and `swarm/scripts/swarm-down.sh` are shared
verbatim. Ultraswarm only adds the extreme layer on top. Read the base skill's
`skills/swarm/SKILL.md` for the parts inherited unchanged (partition model §2, launch §5,
teardown).

**Not base `swarm`, not `superpowers:dispatching-parallel-agents`.** If the user just wants
an ordinary fan-out, use `swarm`. If the work fits throwaway subagents inside one session,
use `superpowers:dispatching-parallel-agents`. Ultraswarm is for when the user explicitly
wants it done to an extreme standard.

## Procedure (in order)

0. **Plan gate.** Produce the backlog + partition before anything else if the task is
   extreme/ambiguous; otherwise let workers plan their own fronts.
1. **Cost gate (`doctor`).** Inherit swarm's ≥4-front floor + explicit `y`, with the extreme
   cost line. Fail ⇒ stop.
2. **Skill discovery.** Match a skill stack to each front. caveman + RTK on EVERY front.
3. **Model + effort routing.** Best-fit model/effort per front (`references/model-fit.md`).
4. **Scaffold** the `.swarm/` blackboard + the extreme `goals/` and `review/` additions
   (`references/blackboard-extreme.md`).
5. **Emit** one extreme kickoff per front + the extended manager cheat-sheet
   (`references/extreme-kickoff-template.md`).
6. **(Optional) Launch** — macOS + alacritty only, after the `y`: `scripts/ultraswarm-up.sh`
   opens the dashboard, then delegates to `swarm/scripts/swarm-launch.sh`.
7. **Manage**, then run a **final global `/code-review ultra`** on the merged result.

## 0. Plan gate

Ultraswarm is invoked for the hard jobs, so decide the plan discipline up front and say
which path you took:

- **Extreme / ambiguous / architectural backlog** → plan the partition FIRST. Use plan mode
  (or `superpowers:writing-plans`) to produce the front list, ownership, feeders, and each
  front's completion condition before you emit anything. The plan is the source of the
  `/goal` conditions in step 5.
- **Already-crisp backlog** → skip the up-front plan and let each worker plan its own front
  with `superpowers:brainstorming` → `superpowers:writing-plans` (these are in every front's
  stack anyway). Announce that you took the lighter path.

## 1. Cost gate (`doctor`) — run first, every time

Inherit the swarm cost gate **verbatim** (`skills/swarm/SKILL.md` §1): detect candidate
fronts, run the pairwise independence test, **refuse below 4 disjoint fronts**, and require
an explicit `y` before emitting anything. Extreme adds cost — state the fuller line:

```
ultraswarm doctor
  fronts found:        <N>
  independent?         <yes | collapsed M→N>
  below floor (<4)?    <no | YES → refusing>
  est. cost:           ~<N>× session + <N>× goal-loops + <N>× ultrareview + 1 global ultrareview  ⚠
  > confirm extreme fan-out? [y/N]
```

On the refuse path (below floor), print the refusal and redirect to `swarm` (for an ordinary
fan-out that still clears the floor) or `superpowers:dispatching-parallel-agents` — never ask
to confirm a swarm you are refusing. No `y` ⇒ emit nothing.

## 2. Skill discovery (per front)

Every front carries a **skill stack** — the skills its worker must load. Build it per front:

- **Mandatory baseline on EVERY front (token + process):** caveman (terse mode, token
  control) + RTK (automatic via the `PreToolUse(Bash)` hook) + the superpowers process spine
  (`brainstorming` → `writing-plans` → `test-driven-development` →
  `verification-before-completion`).
- **Domain skills matched to the front's content** — scan the available skill catalog and
  attach what fits (e.g. Rust → `tdd-rust` + `security-guardian`; Go → `golang-pro`; frontend
  → `frontend-design`; copy/brand → `sexy-copy`; cleanup → `refactor`).

See `references/skill-discovery.md` for the matching method. Record each front's stack in its
kickoff prompt (step 5) so the worker loads exactly those skills — nothing missed, nothing
irrelevant burning tokens.

## 3. Model + effort routing (per front)

Assign each front the **best-fit model and effort** for its task type using the matrix in
`references/model-fit.md`. Write them into the `launch.tsv` manifest's optional `model` /
`effort` columns (`swarm-launch.sh` already reads them). Hard rules from the matrix:

- Architecture / security-critical / hard reasoning → `opus`, `high`/`ultracode`.
- Standard feature code → `sonnet`, `high`.
- Mechanical (rename/format/test-scaffold) → `haiku` (or `sonnet` if nontrivial), `medium`.
- Creative / narrative / brand prose → `fable` (Fable 5), `medium`/`high`.
- **Never `fable` on an `ultracode`/code-refinement mission. Never `haiku` on architecture.**
  Effort scales with front RISK, not size.

## 4. Scaffold the blackboard

Scaffold the standard `.swarm/` exactly as base swarm does (`skills/swarm/SKILL.md` §3 +
`skills/swarm/references/blackboard-protocol.md`): gitignore `.swarm/`, write `blackboard.md`,
`contracts/`, `log.md`; resolve the repo root with `git rev-parse --show-toplevel`.

Then apply the **extreme delta** in `references/blackboard-extreme.md`: add `goal_met` and
`reviewed` columns to `blackboard.md`, and create `goals/` (one file per front: the explicit
`/goal` condition + met flag) and `review/` (one file per front: the `/code-review ultra`
verdict). **A front is `done` ONLY when `goal_met=yes` AND `reviewed=clean`.**

## 5. Emit

Emit one extreme kickoff per front (feeders first) + the extended manager cheat-sheet, using
`references/extreme-kickoff-template.md`. Each front prompt is the base swarm worker prompt
PLUS:

- a **caveman preamble** at the front's assigned level — `ultra` for mechanical fronts,
  `full` for contract/architecture-heavy fronts (keep the terser level off the fronts whose
  contracts other fronts must read cleanly);
- the front's **skill stack** from step 2;
- a **`/goal` line** locking the front's completion condition ("all items merged, gates green,
  `/code-review ultra` clean, contract published if feeder") so the worker persists across
  turns until it is truly met;
- a **self-gate**: before flipping status to `done`, run `/code-review ultra`, write the
  verdict to `review/<front>.md`, and set `reviewed`. Address findings before `done`.

Populate `<gates>` and `<language>` from the target repo exactly as base swarm §4 instructs;
emit unknowns as `<TODO: …>`.

## 6. Launch (optional — macOS + alacritty only) + dashboard

Skip unless the user asked to auto-launch AND you are on macOS with `alacritty`; otherwise
stay emit-only and hand the human the prompts + the dashboard command below. After the `y`:

1. Write prompts to `.swarm/prompts/<front>.md` and the manifest `.swarm/launch.tsv`
   (`front⇥branch⇥promptfile⇥model⇥effort`) exactly as base swarm §5 — the `model`/`effort`
   columns come from step 3.
2. Run `scripts/ultraswarm-up.sh <repo-root>`: it opens the read-only
   **`ultraswarm:dashboard`** window, then delegates to `swarm/scripts/swarm-launch.sh` for
   the front windows (which pre-creates worktrees serially and starts each worker).

**Live dashboard.** A read-only TUI (`scripts/ultraswarm-dashboard.sh <repo-root>`), polling
~2s, showing: the fronts table (front · model · effort · status · goal_met · reviewed) from
`blackboard.md`; the live event feed from `log.md`; per-front + total **tokens used** (summed
from each `swarm-<front>` session JSONL) and estimated **tokens saved** (from `rtk gain` +
caveman heuristic); and the running-cost line. On the emit-only path (any OS), tell the human
to run `bash skills/ultraswarm/scripts/ultraswarm-dashboard.sh <repo-root>` in a spare
terminal. Token figures need a real local shell; with none (cloud/phone) the dashboard
degrades to the blackboard + log panels and labels the token panel unavailable. "Saved" is a
labelled estimate, not an exact per-run figure.

## 7. Manage + final review

Adopt the extended manager cheat-sheet. Run the base swarm manager loop
(`skills/swarm/SKILL.md` §6) plus: reconcile `goal_met` from `goals/` and `reviewed` from
`review/`; chase fronts that are code-complete but not goal-met or not review-clean; keep the
cost reminder loud. Never write code, never merge.

When all fronts reach `done` and merge, run **one final global `/code-review ultra`** on the
integrated result to catch cross-front issues, and report the verdict to the human. Teardown
with `swarm/scripts/swarm-down.sh <repo-root>` (add `--windows` to also close the front
windows and the dashboard).
