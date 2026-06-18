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
