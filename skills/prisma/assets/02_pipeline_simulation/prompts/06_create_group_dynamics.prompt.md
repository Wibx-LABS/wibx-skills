# Prompt 06 — Criar Group Dynamics

> Use depois de personas + Speaking Balance + Response Structure.

---

## Instrução para o modelo

Gere `group_dynamics.json` conformado a `schemas/group_dynamics.schema.json`.

### Decisões a tomar

1. **Tipos de interação permitidos** — escolher entre: agreement, disagreement, challenge, build_on, clarify, reframe, translate_aggression, impose_constraint, good_cop_reframe, ou tipos custom específicos do cenário.
2. **Padrões textuais por interação** — use placeholders `{persona_name}`, `{other_persona}`, `{specific_point}`. Cada padrão deve soar coerente com `language_signature` das personas envolvidas.
3. **Conflict rules** — `encourage_productive_conflict: true` quase sempre. `max_conflict_intensity` calibrado pela tensão do Story Board (negotiation → high, brainstorm → medium, panel → low).
4. **Alignment rules** — após disputa grande, gerar resumo de alinhamento? Quase sempre sim.
5. **Turn-taking** — permitir interrupções? Quando? As condições devem rastrear para `priority_situations` do `speaking_balance.json`.
6. **Coalitions** — permitidas? Quando duas personas se aliam contra o usuário ou contra outra persona? Padrões textuais.
7. **Repair moves** — frases para descomprimir quando o conflito esquenta demais sem ganho.
8. **Ping-pong rules** — `max_back_and_forth_between_pair: 2-3`; ação quando excedido: `force_focus_to_user` ou `force_alignment_summary`.

### Saída

JSON conformado, sem narrativa.
