# Skill discovery — matching a skill stack to each front

Every front worker loads a **skill stack**: the exact skills it needs, and no more. Missing a
relevant skill loses rigor; loading irrelevant ones burns tokens. Build the stack per front
and record it in the front's kickoff prompt.

## Mandatory baseline (EVERY front)

Attach these to every front regardless of content:

- **caveman** — terse mode for token control. The kickoff injects the caveman preamble at the
  front's assigned level (`ultra` for mechanical fronts, `full` for contract/architecture
  fronts). This is the worker-side half of the token discipline.
- **RTK** — automatic. RTK rewrites Bash output via the global `PreToolUse(Bash)` hook
  (`rtk hook claude`), 0 tokens overhead, nothing to prefix. On the local CLI it is already
  on; the kickoff just reminds the worker to lean on the shell rather than pasting raw output.
- **superpowers process spine** — `superpowers:brainstorming` → `superpowers:writing-plans` →
  `superpowers:test-driven-development` (code fronts) → `superpowers:verification-before-completion`.
  Plus `superpowers:using-git-worktrees` on the emit-only path (worker creates its worktree).

## Domain skills — match to the front

Scan the available skill catalog (the skills listed to this session) and attach any that fit
the front's `owned_paths` and backlog items. Common matches:

| Front signal | Add to stack |
|---|---|
| Rust code, `*.rs`, Cargo | `tdd-rust`, `security-guardian`, `design-patterns`, `code-simplifier` |
| Go code, `*.go`, services | `golang-pro` |
| Frontend, UI, components, CSS, pages | `frontend-design` (+ `tailwind`/`expo-tailwind-setup` if that stack) |
| Copy, headline, landing text, brand voice | `sexy-copy` |
| Refactor / cleanup / structural improvement | `refactor` |
| n8n workflows | `n8n` |
| Document ingestion / PDF→MD | `docling-parser` |
| Deck / slides / presentation | `wibx-presentations` |
| Security scan / audit of the front | `security-audit` |
| Prompt/agent artifacts | `prompt-engineer` |

This table is illustrative, not exhaustive — the point is the **method**: read the front,
name the skills that match, drop the rest.

## Method

1. Start every front with the mandatory baseline above.
2. Read the front's `owned_paths` + items; identify its dominant technology and deliverable
   type.
3. Attach the matched domain skills. When unsure whether a skill helps, leave it out — a
   worker can always invoke a skill mid-flight; a bloated preload cannot be un-spent.
4. Write the final stack into the kickoff prompt's "Skill stack" line so the worker loads
   exactly those.
