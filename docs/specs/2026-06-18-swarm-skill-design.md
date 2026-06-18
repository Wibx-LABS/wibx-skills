# Design — `swarm` skill

**Date:** 2026-06-18
**Repo:** Wibx-LABS/wibx-skills → `skills/swarm/`
**Status:** approved design, pre-implementation

## Context

Running many CC instances in parallel to clear a large backlog is powerful but
**expensive and easy to overuse** — each instance is a separately-billed full session.
A real run (8 workers + 1 manager clearing the MAESTRO Backend/Infra/Produto backlog)
proved the pattern works *when* work is partitioned so no two instances touch the same
files, decisions that gate others ship first, and a shared substrate keeps everyone from
diverging. This skill captures that pattern as a reusable, **cost-disciplined** procedure.

It is deliberately **manager-only**: the skill never spawns the workers itself. It plans
the partition, scaffolds a shared blackboard, and emits paste-ready prompts the human
launches manually — so the human throttles the expensive axis (N).

**Not a duplicate of** `superpowers:dispatching-parallel-agents`. That skill dispatches
ephemeral in-session subagents that share *one* session's context/budget and require no
shared state. `swarm` coordinates **N separate full instances** (separately billed) through
an external file blackboard, with worktree isolation and a manager role.

## Goals / non-goals

- **Goal:** turn a text backlog into a collision-free N-front partition + `.swarm/`
  blackboard + N kickoff prompts + a manager loop.
- **Goal:** make accidental/over-fan-out hard (hard floor + forced cost justification +
  explicit-only trigger).
- **Non-goal:** spawning worker processes (human does that).
- **Non-goal:** Notion or any external-service coupling (input is plain text; Notion sync,
  if any, is a manual manager step outside the skill).

## Decisions (locked)

| Decision | Choice |
|---|---|
| Mode | **Manager-only** — plan + emit prompts; invoking session becomes manager (no code) |
| Blackboard | **Local `.swarm/` dir** at repo root, gitignored, shared across worktrees |
| Cost gate | **Hard floor (<4 independent fronts ⇒ refuse) + forced cost confirmation**; explicit-trigger-only |
| Input | **Generic text** backlog (list / markdown / issue dump); no Notion dependency |
| Name | `swarm` |

## §1 Trigger & scope (the discipline)

Fires **only** on explicit fan-out intent: "swarm this backlog", "fan out", "run N
instances", "split across agents". **Never** auto-fires on a vague "do several things" —
that stays inline with one agent. The description must be written so it does *not* trigger
on generic parallelism talk.

## §2 Cost gate / `doctor` (runs FIRST, every invocation)

Before emitting anything:
1. **Detect fronts** from the backlog.
2. **Independence test:** if any two candidate fronts share a package / dir / file, collapse
   them. Repeat until fronts are pairwise disjoint.
3. **Hard floor:** `< 4` truly independent fronts ⇒ **refuse**, advise doing it inline with
   one agent (or `dispatching-parallel-agents` for independent in-session subtasks).
4. **Cost line:** print `N instances ≈ N× a full session ⚠`.
5. **Require explicit `y` confirm.** No confirm ⇒ no emit.

```
swarm doctor
  fronts found:        8
  independent?         yes (disjoint dirs)
  below floor (<4)?    no
  est. cost:           ~8× session  ⚠
  > confirm fan-out? [y/N]
```

## §3 `.swarm/` blackboard + divergence guard

Lives at **main repo root, gitignored**, shared by all worktrees. Each instance reads/writes
it via the **absolute main-repo path** — which is exactly how a git worktree writes back to
the main tree (the worktree-write-path behavior becomes the sharing mechanism on purpose).

```
.swarm/
  blackboard.md   # table: front | owner | branch | owned-paths | status | blocked-reason
  contracts/      # interfaces/decisions others depend on (e.g. f2-authz.md, f8-webfetch.md)
  log.md          # append-only: claims, contract-published, status changes, blockers
```

**Protocol every worker follows** (encoded in its kickoff prompt):
1. **On wake:** read `blackboard.md` + `log.md`.
2. **Claim:** write itself as owner of its front (abort if already owned by another).
3. **Before building a shared edge:** check `contracts/` for the upstream contract; if missing
   and it's a feeder, wait / ping manager.
4. **Publish early:** write its own contract to `contracts/` as soon as the interface is fixed.
5. **Append** every state change to `log.md` (the divergence guard — manager reconciles from it).

Manager **reads** the blackboard; **never edits another front's rows or code**.

## §4 Partitioning rule

A front owns a set of paths no other front touches (**disjoint ownership** = collision-free
parallel). **Feeder fronts** — those producing a decision/contract others depend on — are
flagged to **ship first**; downstream fronts build behind an interface until the contract lands.

## §5 Emitted artifacts

- **Per front:** a kickoff prompt = front scope + owned paths + branch + "use git-worktrees" +
  the `.swarm/` blackboard path + the §3 protocol + the repo's validation gates + "claim on the
  blackboard before doing anything."
- **One manager cheat-sheet:** how to read the blackboard, the feeder order, what to escalate.

## §6 Manager loop

Read `blackboard.md`/`log.md` → tally status across fronts → chase unmet feeder contracts →
escalate blockers + ready-for-review work to the human. **Does not** merge, **does not** code.

## §7 Testing (skill-creator eval)

Feed sample backlogs and assert:
- Refuses when `< 4` fronts or fronts aren't independent.
- Does **not** trigger on generic "do these in parallel" phrasing (description-trigger eval).
- On a valid backlog: produces pairwise-disjoint fronts, a well-formed `.swarm/` scaffold,
  N kickoff prompts, and a manager cheat-sheet.

## Open items

- Exact `blackboard.md` / `log.md` line formats (finalize in implementation).
- Whether to ship a tiny helper script for the `doctor` count, or keep it prose-procedural
  (lean prose-first to stay zero-install per the tooling-four-laws).
