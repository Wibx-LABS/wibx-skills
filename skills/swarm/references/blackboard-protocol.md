# `.swarm/` blackboard protocol

The blackboard is the shared substrate that keeps separate instances from diverging.
It lives at the **target repo root**, is **gitignored**, and is **shared across all
worktrees**: each instance reads and writes it via the *absolute main-repo path*, which
is exactly how a git worktree writes back into the main tree. (Heads-up: an absolute
main-repo path from inside a worktree lands in the MAIN tree, not the worktree checkout —
here that's the feature, not a bug.)

## Layout

```
.swarm/
  blackboard.md   # one row per front: state + ownership
  contracts/      # one file per published interface/decision others depend on
  log.md          # append-only event log — the divergence guard
  prompts/        # launcher-only: <front>.md kickoff + optional <front>.system.md guard
  worktrees/      # launcher-only: one git worktree checkout per front
  launch.tsv      # launcher-only: front⇥branch⇥promptfile[⇥model⇥effort] manifest
```

`prompts/`, `worktrees/`, and `launch.tsv` exist only when the optional macOS+alacritty
launch step (SKILL.md §5) is used; the manual emit-only path never creates them.

## blackboard.md template

```markdown
# Swarm blackboard — <backlog title>
updated: <iso8601 by manager>

| front | owner | branch | owned_paths | status | blocked_reason |
|-------|-------|--------|-------------|--------|----------------|
| gateway-authz | (unclaimed) | feat/gateway-authz | backend/gateway/** | todo | |
| radar-fetch   | (unclaimed) | feat/radar-fetch   | engine/.../m4 + search | todo | |

status ∈ {todo, claimed, in_progress, review, done, blocked}
```

## log.md template (append-only)

```
<iso8601> <front> CLAIM owner=<instance-id>
<iso8601> <front> CONTRACT published contracts/<file>
<iso8601> <front> STATUS in_progress→review pr=<url>
<iso8601> <front> BLOCKED reason="<why>"
```

## contracts/<front>.md template

```markdown
# Contract: <front>
status: draft | stable
interface:
  <the exact signatures / data shape / decision downstream fronts must build against>
notes:
  <anything a consumer needs; link the PR once it lands>
```

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
