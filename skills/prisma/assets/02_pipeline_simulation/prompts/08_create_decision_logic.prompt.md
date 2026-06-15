# Prompt 08 — Criar Decision Logic

> Use depois de personas + 4 anteriores prontos.

---

## Instrução para o modelo

Gere `decision_logic.json` conformado a `schemas/decision_logic.schema.json`.

### Decisões a tomar

1. **min_turns_before_decision** — quanto exploração mínima antes de aceitar um veredito. Padrão: 6-8.
2. **max_turns** — limite duro. Padrão: 20-25. Em simulações complexas até 30.
3. **outcomes** — mínimo 2, mais comum 3. Cada um com `label`, `description` (1-2 linhas) e `conditions` (objeto com chaves booleanas que precisam todas ser true para o veredito).
4. **veto_rules** — quais personas têm poder de veto? `levels: ["concern", "blocker"]` é a convenção PRISMA. `patterns` textuais por nível: `concern` deve sinalizar peso, `blocker` deve travar a decisão.
5. **decision_trigger_rules** — `check_for_decision_every_n_turns: 3-4`. `ask_user_if_ready_for_decision: true` quase sempre. `decision_prompt_pattern` deve ser ambientado no cenário.
6. **final_output_structure** — formato do veredito: `decision`, `summary_rationale`, `unresolved_risks[]`, `required_next_steps_for_user[]`, `recommended_experiments[]`. Os campos opcionais que valem a pena: `score_per_dimension`, `time_to_decision`.
7. **evaluation_dimensions** — 2-4 eixos numéricos (`scale: "0-10"`) que medem aspectos distintos. Cada dimensão deve mapear para um ângulo de persona (ex.: `financial_discipline` → Alex; `operational_feasibility` → Dan).
8. **min_scores_for_approval** — gatekeeper numérico. Soma das mínimas precisa ser atingível mas não trivial.
9. **fallback_if_no_consensus** — `after_turn: max_turns - 2`. `default_decision` deve ser o outcome mais conservador. `rule` explica em prosa quando dispara.

### Regras duras

- Cada `persona_id` em `veto_rules.personas_with_veto_power` precisa existir.
- Cada `outcome.conditions` deve usar chaves que façam sentido no cenário (não inventar campos abstratos).
- `fallback_if_no_consensus.after_turn` < `max_turns`.
- `min_scores_for_approval` deve referenciar nomes de dimensions existentes em `evaluation_dimensions`.

### Saída

JSON conformado, sem narrativa.
