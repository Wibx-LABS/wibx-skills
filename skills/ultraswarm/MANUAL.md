# ultraswarm — manual

## EN

The extreme variant of `swarm`. Same engine (`.swarm/` blackboard, git-worktree isolation,
`swarm/scripts/swarm-launch.sh`), plus: a plan-first gate, a matched skill stack + caveman +
RTK on every front (token discipline), best-fit model/effort per front, a `/goal` lock per
worker, and `/code-review ultra` on every front and on the merged result — with an optional
live dashboard.

Use it only when the user explicitly wants an **extreme / ultra / maximum-rigor** fan-out
("ultraswarm this backlog", "extreme swarm these fronts", "swarm this hard and nail it"). For
an ordinary fan-out use `swarm`; for parallel subtasks inside one session use
`superpowers:dispatching-parallel-agents`.

Flow: **plan → doctor (≥4 fronts, explicit `y`) → skill stacks → model/effort routing →
scaffold `.swarm/` (+ `goals/`, `review/`) → emit extreme kickoffs → (optional) launch +
dashboard → manage → final global `/code-review ultra`.** A front is done only when its goal
is met AND its ultrareview is clean.

Dashboard (read-only): `bash skills/ultraswarm/scripts/ultraswarm-dashboard.sh <repo-root>` —
fronts table, live log feed, tokens used (per front + total, from session transcripts) and
tokens saved (estimate, from `rtk gain`), cost line. Token figures need a local shell; without
one the token panel is unavailable and the rest still works.

Auto-launch (macOS + alacritty, after the `y`):
`bash skills/ultraswarm/scripts/ultraswarm-up.sh <repo-root>` (opens the dashboard, then the
front windows). Teardown: `bash skills/swarm/scripts/swarm-down.sh <repo-root> --windows`.

## PT-BR

Variante extrema do `swarm`. Mesmo motor (`.swarm/`, worktrees, `swarm-launch.sh`), mais:
plano primeiro, pilha de skills + caveman + RTK em cada frente (disciplina de token), modelo/
esforço sob medida por frente, trava `/goal` por worker, e `/code-review ultra` em cada frente
e no resultado final — com dashboard ao vivo opcional.

Use só quando o usuário pedir explicitamente fan-out **extremo / ultra / de rigor máximo**.
Para fan-out comum use `swarm`; para subtarefas paralelas numa sessão só use
`superpowers:dispatching-parallel-agents`.

Fluxo: **plano → doctor (≥4 frentes, `y` explícito) → pilhas de skills → roteamento de modelo/
esforço → montar `.swarm/` (+ `goals/`, `review/`) → emitir kickoffs extremos → (opcional)
launch + dashboard → gerenciar → `/code-review ultra` global final.** Uma frente só está pronta
quando a meta é atingida E o ultrareview está limpo.

Dashboard (somente leitura):
`bash skills/ultraswarm/scripts/ultraswarm-dashboard.sh <repo-root>`.
Auto-launch (macOS + alacritty, após o `y`):
`bash skills/ultraswarm/scripts/ultraswarm-up.sh <repo-root>`.
