# Prompt 05 — Criar Response Structure

> Use depois de ter Story Board, personas e Speaking Balance prontos.

---

## Instrução para o modelo

Gere `response_structure.json` conformado a `schemas/response_structure.schema.json`.

### Decisões a tomar

1. **Persona block** — qual header (ex.: `[{persona_name} – {role_title}]`), incluir body_language? incluir energy_level? incluir emotional_tone?
2. **Status block** — incluir? Se sim: `summary_of_agreements`, `summary_of_disagreements`, `key_tensions`, `open_questions`. Os `key_tensions` devem rastrear para a tensão central declarada no Story Board.
3. **Next move block** — incluir? Se sim: `suggested_user_actions`, `decision_checkpoint`, `confidence_level`.
4. **Ordem das seções** — convenção PRISMA: `status_block` → `persona_blocks` → `next_move_block` (a tensão é o contexto, as personas respondem dentro dela, o próximo movimento fecha).
5. **Machine-readable summary** — recomendado: `decision_hint`, `top_risks`, `top_opportunities`. Útil quando a simulação alimenta downstream automation.
6. **Verbosidade** — `mode: auto` por padrão. `short_mode_max_tokens: 200-300`, `long_mode_max_tokens: 700-1000`.

### Saída

JSON conformado, sem narrativa.
