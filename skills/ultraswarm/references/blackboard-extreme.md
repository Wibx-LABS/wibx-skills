# Blackboard — extreme delta

Ultraswarm uses the base `.swarm/` blackboard unchanged
(`skills/swarm/references/blackboard-protocol.md`) and adds two columns + two directories so
"done" means *goal met and reviewed clean*, not just *code landed*.

## Layout delta

```
.swarm/
  blackboard.md   # base + two extra columns: goal_met, reviewed
  contracts/      # unchanged (base swarm)
  log.md          # unchanged (base swarm) — append every transition
  goals/          # NEW: one file per front — the explicit /goal condition + met flag
  review/         # NEW: one file per front — the /code-review ultra verdict
  prompts/ worktrees/ launch.tsv   # launcher-only (base swarm §5), unchanged
```

## blackboard.md template (extended)

```markdown
# Ultraswarm blackboard — <backlog title>
updated: <iso8601 by manager>

| front | owner | branch | owned_paths | status | goal_met | reviewed | blocked_reason |
|-------|-------|--------|-------------|--------|----------|----------|----------------|
| gateway-authz | (unclaimed) | feat/gateway-authz | backend/gateway/** | todo | no | — | |
| radar-fetch   | (unclaimed) | feat/radar-fetch   | engine/.../m4 + search | todo | no | — | |

status   ∈ {todo, claimed, in_progress, review, done, blocked}
goal_met ∈ {no, yes}                    # yes only when the front's /goal condition is met
reviewed ∈ {—, findings, clean}         # clean only when /code-review ultra passed
DONE RULE: a front is truly done only when status=done AND goal_met=yes AND reviewed=clean.
```

## goals/<front>.md template

```markdown
# Goal: <front>
condition: <the exact /goal completion condition the worker locked>
met: no        # worker flips to yes when the condition holds
notes: <evidence — merged PR urls, gate output, contract link>
```

## review/<front>.md template

```markdown
# Review: <front>
tool: /code-review ultra
verdict: <clean | findings>
ran: <iso8601>
findings:
  <none, or the list of issues the worker must resolve before done>
```

## Extra worker steps (on top of base swarm worker protocol)

The base protocol (claim → check contracts → publish early → log every transition) is
unchanged. Extreme adds:

- **Lock the goal first.** After claiming, run `/goal <condition>` and write `goals/<you>.md`.
- **Review before done.** Before `status=done`, run `/code-review ultra`, write
  `review/<you>.md`, and set `reviewed`. `findings` ⇒ fix and re-review; only `clean` +
  `goal_met=yes` allows `done`.

## Extra manager reconciliation

The manager still reconciles only from `log.md` + the blackboard, and never edits another
front's content. It additionally reads `goals/<front>.md` and `review/<front>.md` to fill the
`goal_met` / `reviewed` columns, and treats a front as complete only under the DONE RULE
above.
