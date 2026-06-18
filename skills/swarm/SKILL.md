---
name: swarm
description: Partition a backlog into disjoint parallel "fronts" and emit ready-to-launch prompts for several SEPARATE Claude Code instances, coordinated through a shared .swarm/ blackboard, with the invoking session acting as a no-code manager. Use ONLY when the user explicitly asks to fan out / swarm / split a backlog across many separate CC instances or agents — phrasings like "swarm this backlog", "fan out across N agents", "run 6 instances in parallel on these", "divide this into fronts for parallel agents". A hard cost gate refuses fewer than 4 truly independent fronts and forces an explicit cost confirmation, because each instance is a separately-billed full session and this is expensive when overused. Do NOT use for ordinary parallel subtasks inside one session (that is superpowers:dispatching-parallel-agents), and do NOT use for any work a single agent can do.
---

# Swarm

Turn a backlog into a collision-free, multi-instance attack plan — and act as the
manager who keeps the instances from diverging — without spending more than the job
is worth.

**This skill plans and emits.** You produce the partition, the shared blackboard, and the
paste-ready prompts; by default the human starts the instances, which keeps the expensive
axis (how many instances) under human control. On macOS with `alacritty`, an **opt-in**
final step can launch the confirmed fan-out for you (step 6) — but only *after* the cost
gate's `y`, so the human still decides how many instances to pay for.

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
5. **(Optional) Launch** — only on macOS+alacritty, only after the doctor `y`: open one
   positioned window per front, each starting its worker. Skip on any other platform.
6. Become the **manager**: track the blackboard, chase feeders, escalate. No code.

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

```
swarm doctor
  fronts found:        <N>
  independent?         <yes | collapsed M→N>
  below floor (<4)?    <no | YES → refusing>
  est. cost:           ~<N>× session  ⚠
  > confirm fan-out? [y/N]
```

On the **refuse path** (below floor), print the refusal and recommendation in place of the `confirm fan-out?` line — never ask to confirm a swarm you are refusing.

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

## 3. Scaffold the blackboard

Create `.swarm/` at the target repo root and add `.swarm/` to `.gitignore`. Write
`blackboard.md` with one row per front (status `todo`, owner `(unclaimed)`), create an
empty `contracts/`, and start `log.md`. Use the exact templates and the worker protocol in
`references/blackboard-protocol.md` — that protocol is what each instance follows to avoid
divergence, and it is embedded by reference into every kickoff prompt.

Resolve the repo root with `git rev-parse --show-toplevel`; that absolute path is what
fills `<repo-root>` in every emitted prompt, because workers in their own worktrees must
reach the shared blackboard via the absolute main-repo path.

## 4. Emit

Using `references/kickoff-template.md`, output one filled kickoff prompt per front
(feeders first) and one manager cheat-sheet. Before emitting, populate `<gates>` from the
target repo's validation commands — check its CLAUDE.md, Makefile, package.json scripts,
or CI config — and `<language>` from its PR/commit convention; if a value cannot be
determined, emit it as `<TODO: ...>` so the worker resolves it explicitly instead of
shipping unvalidated. Hand these to the human to launch — you do not start them.

## 5. Launch (optional — macOS + alacritty only)

**Skip this entire section unless the user asked to auto-launch AND you are on macOS with
`alacritty` installed.** On any other setup, stay emit-only: hand the kickoff prompts to the
human (step 4) and go straight to managing. Launch runs **only after the doctor `y`** — it
never changes how many instances exist, it just opens the ones the human already paid for.

To launch:

1. Write each front's filled kickoff prompt to `.swarm/prompts/<front>.md` (durable artifact;
   avoids quoting a multi-line prompt on the command line).
2. Write the manifest `.swarm/launch.tsv`, one TAB-separated row per front:
   `front⇥branch⇥promptfile` — `promptfile` relative to the repo root
   (`.swarm/prompts/<front>.md`). Optionally append `⇥model⇥effort` to tune a heavy front up
   (`opus`/`high`) or a trivial one down.
3. **Optional scope guard:** for any front, write `.swarm/prompts/<front>.system.md` restating
   its `owned_paths`, "never edit outside them", and the absolute blackboard path. The launcher
   passes it via `--append-system-prompt`, enforcing scope at the system level, not just the
   user prompt.
4. Run `scripts/swarm-launch.sh <repo-root>`. It refuses if alacritty is missing, the manifest
   is absent, or fewer than 4 rows remain (defense-in-depth mirror of the floor). It
   **pre-creates each worktree serially** (concurrent `git worktree add` from N windows would
   race on git's repo lock), then opens one positioned window per front — titled
   `swarm:<front>`, parked in an auto-computed screen grid, `cd`'d into its worktree — and
   starts each worker autonomously.

Each worker launches via the user's `cc` function (`claude --dangerously-skip-permissions`),
plus `--add-dir <repo>/.swarm` (so the worktree can reach the shared blackboard, which sits
above its cwd) and `-n swarm-<front>` (so the session is named in the prompt box / `/resume`
picker / title — a dead window is recoverable with `cc -c` in its worktree).

> **Cost & safety:** launched workers run with permissions bypassed and start immediately, so
> N windows are spending in parallel from the moment they open. Keep the running-cost reminder
> loud; the `swarm:<front>` titles make idle windows easy to spot. Teardown:
> `scripts/swarm-down.sh <repo-root>` (add `--windows` to also close them).

Because the launcher creates the worktree and drops the window inside it, the auto-launch
kickoff variant tells the worker its worktree **already exists** (it does not create one). The
emit-only path keeps the original "create your worktree" wording. See
`references/kickoff-template.md`.

## 6. Manage

Adopt the manager cheat-sheet yourself. Read the blackboard, tally status, chase unmet
feeder contracts, escalate blockers and review-ready PRs to the human, and reconcile rows
from `log.md`. Never write code, never edit another front's files, never merge. Remind the
human of the running cost so idle instances get stopped.
