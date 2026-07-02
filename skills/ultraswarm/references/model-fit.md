# Model + effort routing

Each front runs a separately-billed instance. Match its **model** and **effort** to the
front's task type so you spend power where it pays and save it where it doesn't. Write the
chosen values into the `model` / `effort` columns of `.swarm/launch.tsv`
(`front⇥branch⇥promptfile⇥model⇥effort`); `swarm-launch.sh` passes them as `--model` /
`--effort`.

## Matrix

| Front task type | Model | Effort |
|---|---|---|
| Architecture / system design / security-critical / hard cross-cutting reasoning | `opus` | `high` (or `ultracode` for the single hardest front) |
| Standard feature build (new code, real logic) | `sonnet` | `high` |
| Mechanical: refactor, rename, format, test-scaffold, mechanical migration | `haiku` (bump to `sonnet` if the change is nontrivial) | `medium` |
| Creative / narrative / copy / brand / marketing prose | `fable` (Fable 5) | `medium` (or `high` for the flagship piece) |

## Hard rules (non-negotiable)

- **Never `fable` on an `ultracode`/code-refinement mission.** Fable 5 is Mythos-class —
  narrative and creative, not deep-code refinement. Sending it on a precision code pass is
  exactly the mismatch this skill exists to prevent.
- **Never `haiku` on architecture or security-critical work.** Underpowering the front that
  everyone else depends on poisons every downstream contract.
- **Effort scales with front RISK, not front size.** A ten-line change to an auth boundary is
  `high`; a thousand-line mechanical rename is `medium`. Size is a weak proxy — risk is the
  real axis.
- **Feeders lean up, not down.** A feeder's contract is consumed by other fronts, so give it
  at least the model/effort its blast radius warrants — never the cheapest tier.

## Deciding a front's type

Read the front's `owned_paths` and its backlog items:

1. Does it define an interface, boundary, or decision others depend on, or touch auth /
   crypto / data integrity? → **architecture/security** row.
2. Is it new product logic with real branching and tests? → **standard feature** row.
3. Is it a repeat edit across many files with no design decisions (rename, format, codemod,
   test scaffolding)? → **mechanical** row.
4. Is the deliverable prose — docs voice, marketing copy, narrative? → **creative** row.

When a front spans two rows, route by its **riskiest** part, not its bulk.
