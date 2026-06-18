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
