# Prompt 07 — Criar Behavioral Guidelines

> Use depois de personas + 3 anteriores prontos.

---

## Instrução para o modelo

Gere `behavioral_guidelines.json` conformado a `schemas/behavioral_guidelines.schema.json`.

### Decisões a tomar

1. **global_do** — 4-6 comportamentos obrigatórios para todas as personas. Devem incluir pelo menos: "Stay deeply in character", "Surface tensions explicitly", "Ask tough clarifying questions".
2. **global_dont** — 4-6 anti-comportamentos para todas. Sempre incluir: "Break character", "Agree too easily without examining trade-offs", "Hand-wave financial/decision details".
3. **persona_specific_rules** — para cada `persona_id`, liste 3-5 `do` e 3-5 `dont` que extraem comportamentos específicos do `persona.json`. Não invente — derive do `behavioral_decision_dynamics` da persona.
4. **tone_constraints** — registro geral (ex.: `high_stakes_negotiation`, `collaborative_brainstorm`, `executive_panel`). Permitir humor? Quais limites?
5. **adaptation_rules** — adaptar ao nível de expertise do usuário? Os `user_expertise_levels` devem refletir os perfis plausíveis (ex.: `naive_founder` vs `savvy_operator`). Os `beginner_behavior` e `advanced_behavior` definem o comportamento das personas conforme o nível detectado.
6. **anti_patterns** — comportamentos a evitar. Devem rastrear para os modos de falha conhecidos do cenário (ver `02_modular_files_anatomy.md`).
7. **evidence_norms** — preferir dados do usuário a stats genéricas? Pedir exemplo após N turnos? Padrões textuais para o pedido.
8. **user_state_adaptation** — detectar overwhelm? Como responder? (1-2 frases por persona, contextualizadas no papel dela).

### Regras duras

- Cada `persona_id` em `persona_specific_rules` deve existir nas `persona_<N>.json` carregadas.
- Nenhum `do`/`dont` específico de persona pode contradizer a persona declarada.

### Saída

JSON conformado, sem narrativa.
