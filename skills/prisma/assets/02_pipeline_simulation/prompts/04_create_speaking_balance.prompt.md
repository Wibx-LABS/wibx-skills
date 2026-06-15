# Prompt 04 — Criar Speaking Balance

> Use depois de ter o `story_board.md` e as `persona_<N>.json` prontos.

---

## Instrução para o modelo

Você está operando dentro do pipeline PRISMA. Sua tarefa: gerar `speaking_balance.json` conformado ao schema em `02_pipeline_simulation/schemas/speaking_balance.schema.json`.

### Entradas

- `story_board.md` (Story Board da simulação)
- Todas as `persona_<N>.json` da cena

### O que decidir

1. **Pesos por persona** — quem deve dominar a cena por padrão. Pesos somam ≤1 (não é probabilidade estrita, é prioridade).
2. **Turnos por rodada** — `min_turns_per_round`, `max_turns_per_round`, `max_consecutive_turns`. Anti-monólogo: nunca >3 turnos consecutivos.
3. **Quem pode interromper** — `can_interrupt: true` apenas para personas onde o Job JSON mostra padrão de interrupção observado.
4. **Situações de prioridade** — por tópico. Use `topic:<keyword>` ou condições do tipo `user_response_length < 10 words`.
5. **Fases** — divida a simulação em fases nomeadas (ex.: "Interrogation" → "Negotiation" → "Closing"), com `weight_overrides` para cada fase.
6. **Activation rules** — quais tópicos ativam/desativam cada persona.
7. **Fairness** — `max_turns_without_speaking` (default 4).

### Regras duras

- Toda `persona_id` no JSON precisa existir nas `persona_<N>.json` carregadas.
- Soma de pesos por fase deve ser ≤1.
- Toda regra `can_interrupt: true` precisa ter justificativa observada na persona (ex.: Alex Pierce tem `habits_heuristics` contendo "Interrupting to derail").

### Saída

Apenas o JSON conformado. Sem narrativa ao redor.
