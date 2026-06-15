# 02 — Anatomia dos 8 arquivos modulares

> Referência rápida do que cada arquivo da simulação carrega, com snippet ilustrativo. Para schema completo: `schemas/<arquivo>.schema.json`.

---

## 1. `story_board.md`

Markdown. Sem schema (formato livre seguindo `01_story_board_guide.md`).

Responde a: **quem, qual tensão, qual contexto.**

---

## 2. `persona_<N>.json`

Schema: `01_pipeline_synthetic/schemas/persona.schema.json` (mesmo do pipeline single-persona).

Responde a: **quem é cada persona individualmente.**

Mínimo: 2 personas para fazer sentido como "cena multi-agente". Não há máximo formal, mas >4 personas dilui o foco.

---

## 3. `speaking_balance.json`

Schema: `schemas/speaking_balance.schema.json`

Responde a: **quem fala quando, quanto, em qual fase, com qual prioridade por tópico.**

Estrutura essencial:

```json
{
  "speaking_balance": {
    "default_mode": "weighted_round_robin",
    "personas": [
      {
        "persona_id": "alex-pierce",
        "display_name": "Alex",
        "weight": 0.6,
        "min_turns_per_round": 1,
        "max_turns_per_round": 3,
        "max_consecutive_turns": 2,
        "can_interrupt": true,
        "priority_situations": ["topic:valuation", "topic:equity"]
      }
    ],
    "global_constraints": {
      "ensure_all_personas_speak_by_turn": 4,
      "max_total_turns_per_exchange": 5,
      "allow_user_to_break_sequence": true
    },
    "phases": [
      {
        "name": "Interrogation",
        "from_turn": 1, "to_turn": 10,
        "weight_overrides": { "alex-pierce": 0.7, "dan-reilly": 0.3 }
      }
    ],
    "activation_rules": { "activate_when": [], "deactivate_when": [] },
    "fairness": { "max_turns_without_speaking": 4 }
  }
}
```

---

## 4. `response_structure.json`

Schema: `schemas/response_structure.schema.json`

Responde a: **que formato cada resposta tem na tela.**

Estrutura essencial:

- `persona_block_template` — header, message, body_language, energy_level, emotional_tone, references_to_others.
- `status_block_template` — agreements, disagreements, key_tensions, open_questions.
- `next_move_block_template` — suggested_user_actions, decision_checkpoint, confidence_level.
- `formatting` — ordem das seções, separadores, prefixos.
- `machine_summary_schema` — output JSON paralelo para sistemas downstream.

---

## 5. `group_dynamics.json`

Schema: `schemas/group_dynamics.schema.json`

Responde a: **como as personas interagem entre si.**

Estrutura essencial:

- `allowed_interaction_types` — agreement, disagreement, challenge, build_on, clarify, reframe.
- `interaction_patterns` — template textual para cada tipo (com placeholders `{persona_name}`, `{other_persona}`).
- `conflict_rules` — `encourage_productive_conflict`, `max_conflict_intensity`, `required_when_major_tradeoff`.
- `alignment_rules` — `summarize_alignment_after_major_dispute`.
- `turn_taking_rules` — interruptions permitidas, quando.
- `coalition_rules` — coalizões permitidas, padrões.
- `repair_moves` — frases para descomprimir conflito.
- `ping_pong_rules` — limite de back-and-forth entre par, ação quando excedido.

---

## 6. `behavioral_guidelines.json`

Schema: `schemas/behavioral_guidelines.schema.json`

Responde a: **o que toda persona deve e não deve fazer, com regras específicas por persona.**

Estrutura essencial:

- `global_do` / `global_dont` — válido para todas.
- `persona_specific_rules` — array por persona com `do` e `dont`.
- `tone_constraints` — registro geral + humor boundaries.
- `adaptation_rules` — adaptação ao nível de expertise do usuário (`beginner_behavior` vs `advanced_behavior`).
- `anti_patterns` — comportamentos a evitar.
- `evidence_norms` — preferir dados do usuário, pedir exemplo após N turnos.
- `user_state_adaptation` — detectar sinais de overwhelm e responder.

---

## 7. `decision_logic.json`

Schema: `schemas/decision_logic.schema.json`

Responde a: **como a simulação chega a um veredito.**

Estrutura essencial:

- `min_turns_before_decision` / `max_turns`.
- `outcomes[]` — vereditos possíveis com `conditions` cada.
- `veto_rules` — quem pode vetar, padrão textual.
- `decision_trigger_rules` — checar a cada N turnos.
- `final_output_structure` — formato do veredito final.
- `evaluation_dimensions[]` — eixos `0-10`.
- `min_scores_for_approval`.
- `fallback_if_no_consensus`.

---

## 8. `master_prompt.md`

Markdown. Sem schema. Estrutura recomendada:

```markdown
# <Nome da simulação> — Build prompt

## Input files
story_board.md, persona_alex.json, persona_dan.json, speaking_balance.json,
response_structure.json, group_dynamics.json, behavioral_guidelines.json,
decision_logic.json

## Build a complete simulation with

1. Interactive negotiation following all behavioral/structural rules.
2. AI Hint System — when the student is stuck, provide brief directional guidance (not solutions).
3. Post-Simulation Report including:
   - Student behavior analysis
   - Strengths and weaknesses observed
   - Improvement suggestions
   - Final grade

## Constraints

- Never break character ("I am an AI").
- Always respect speaking_balance.json fairness rules.
- Always emit response_structure.json blocks in order.
- Apply decision_logic.json outcomes only after min_turns_before_decision.
```

Veja `templates/master_prompt.template.md` para o exemplo completo.

---

## Verificação cruzada de consistência

Antes de fazer build, verifique:

| Verificação | Pergunta |
|---|---|
| Persona ↔ Speaking Balance | Cada `persona_id` no `speaking_balance.json` existe em algum `persona_<N>.json`? |
| Persona ↔ Behavioral | Cada `persona_id` em `persona_specific_rules` existe? |
| Persona ↔ Decision Logic | Cada `persona_id` em `veto_rules.personas_with_veto_power` existe? |
| Speaking Balance ↔ Group Dynamics | Se `can_interrupt: true`, então `turn_taking_rules.allow_interruptions: true`? |
| Decision Logic ↔ Story Board | Os `outcomes` cobrem os finais plausíveis do cenário descrito no Story Board? |
| Behavioral ↔ Persona | Os `do`/`dont` por persona são consistentes com a persona declarada (não introduzem comportamentos ausentes)? |

Se qualquer cruzamento falhar, a simulação vai produzir comportamento incoerente. Corrija antes de fazer build.
