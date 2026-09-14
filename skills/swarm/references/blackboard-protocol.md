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
manager: <manager's session name, from the ListAgents header line>

| front | owner | branch | owned_paths | status | blocked_reason |
|-------|-------|--------|-------------|--------|----------------|
| gateway-authz | (unclaimed) | feat/gateway-authz | backend/gateway/** | todo | |
| radar-fetch   | (unclaimed) | feat/radar-fetch   | engine/.../m4 + search | todo | |

status ∈ {todo, claimed, in_progress, review, done, blocked}
```

`manager:` is the only address a worker is given, and the only one it may use.

**It goes stale on its own.** A session's name is not fixed for its lifetime: the same session
(same `ListAgents` ref) was observed renaming itself mid-run, no restart involved. So the
manager re-checks its own name from the `ListAgents` header on every management pass and
rewrites this line when it has drifted — and a worker whose send bounces re-reads the line
before giving up. Never cache the manager's address anywhere else; this line is the only copy
that gets maintained.

This is also why a worker's address is **learned, never predicted** (see `HELLO` below): even
on the launcher path, where the session starts as `swarm-<front>`, the name is a starting value,
not a guarantee.

`owner` doubles as the worker's **message address**: the manager fills it from the `from`
attribute of that front's `HELLO` (see below), so it is correct on both the launcher path
(where it happens to be predictable, `swarm-<front>`) and the emit-only path (where it is not).

## log.md template (append-only)

```
<iso8601> <front> CLAIM owner=<instance-id>
<iso8601> <front> CONTRACT published contracts/<file>
<iso8601> <front> STATUS in_progress→review pr=<url>
<iso8601> <front> BLOCKED reason="<why>"
<iso8601> <front> HELLO addr=<message address>
<iso8601> <front> ASK path=<path> owner=<other front>
<iso8601> <front> GRANT path=<path> to=<other front>
```

The last three are the message channel's paper trail. The channel is volatile; the log is not.

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
3. **Say hello:** `SendMessage` to the `manager:` address — one line, your front name. That
   single message is how the manager learns your address (it reads the `from`) and how it
   subscribes to your liveness. Append a `HELLO` line. Do this once, right after claiming.
4. **Check before shared edges:** if your front `depends_on` a feeder, read its
   `contracts/<feeder>.md`. Missing or `draft`? Build behind a local stub and keep going;
   don't block.
5. **Publish early:** the moment your own interface is fixed, write `contracts/<you>.md`
   (`status: stable`) and append a `CONTRACT` line — downstream fronts are waiting on it.
6. **Handshake before a shared write:** about to edit a path outside your `owned_paths`, or
   about to `git push` (which carries other fronts' commits)? Ask the manager first, append an
   `ASK` line, and wait for the relayed answer. Never edit another front's path on your own
   judgement — that is the lost update this whole protocol exists to prevent.
7. **Append every transition** to `log.md`. The manager reconciles only from the log, so an
   unlogged change is an invisible change.

The manager **reads** the blackboard and reconciles; it never edits another front's row or
code.

## Message channel (star)

The blackboard is the truth. Messages are volatile, carry no authority, and exist for the two
things files do badly: a handshake that needs an answer, and knowing a front went quiet.
Anything that must survive is written to `log.md` — a decision that exists only in a message
did not happen.

The topology is a **star**, and it is enforced by what a worker is told, not by a rule it could
bend:

- A worker is given **exactly one address** — `manager:` — and may talk to nothing else.
- A worker **never runs `ListAgents`.** The machine is full of the human's unrelated sessions;
  a worker has no business discovering them, and a swarm that starts messaging them has become
  an agenda hijack.
- Front-to-front therefore **routes through the manager**, which relays and logs the `GRANT`.
  Two extra hops, and the worker's address book stays a single entry long.

**Permission laundering, both directions.** Launched workers run with permission checks off and
no human watching that window. So: the manager must **never** ask a worker to run something the
manager itself was denied — the worker will simply do it, and the human's refusal is bypassed.
The reverse holds too: a worker that gets blocked routes the problem back through the manager to
the human, it does not shop for a peer who is allowed.
