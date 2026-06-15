# Prompt 12 — Test, Debug, Refine

> Use depois do build da simulação. Itere até cobrir os modos de falha conhecidos.

---

## Áreas de teste

### Persona authenticity & consistency

- Cada persona mantém personagem por 25 turnos sem quebrar?
- Cada persona usa frases coerentes com `language_signature` do seu Job JSON?
- Personas nunca dizem "como uma IA…"?

### Response timing & flow

- `speaking_balance` é respeitado? Ninguém domina mais que o configurado?
- Todas as personas falam pelo menos uma vez antes do turno N (`ensure_all_personas_speak_by_turn`)?
- As fases (`phases`) ativam os pesos corretos nos turnos corretos?

### AI Hint System

- Quando o usuário envia mensagem curta (<10 palavras) ou demora muito, dica direcional é oferecida?
- A dica é direcional, não solução pronta?

### Post-simulation grading

- O Post-Simulation Report cobre os 4 elementos: análise comportamental, forças, fraquezas, sugestões?
- A nota final corresponde aos `evaluation_dimensions` declarados?

### Edge cases

- E se o usuário tenta quebrar personagem? ("Você é uma IA, né?")
- E se o usuário concorda imediatamente com tudo?
- E se o usuário fica em silêncio por muitos turnos?
- E se o usuário tenta pular para a decisão antes de `min_turns_before_decision`?

---

## Debug focus

### Character breaking moments

Quando uma persona quebra: capture o turno, identifique se foi pressão direta do usuário (esperado) ou pressão interna da simulação (bug). Se for bug, reforce o `global_dont` no `behavioral_guidelines.json`.

### Logic inconsistencies in decisions

Quando o veredito final não bate com o histórico da conversa: verifique se `decision_logic.conditions` foram avaliadas corretamente. Frequentemente o problema é `outcomes` mal-especificados.

### Edge case handling

Os edge cases acima precisam ter resposta planejada. Se uma simulação trava num edge case, adicione ao `anti_patterns` e re-deploy.

---

## Refine items

### Ajustar parâmetros nos JSONs

- Pesos do `speaking_balance` quando uma persona domina demais.
- Thresholds do `decision_logic` quando vereditos chegam cedo/tarde demais.
- `behavioral_guidelines.persona_specific_rules` quando uma persona age fora do personagem.

### Fine-tune decision thresholds

- `min_turns_before_decision` ↑ se decisão chega cedo demais.
- `min_scores_for_approval` ↑ se vereditos `approval` estão soltos.
- `fallback_if_no_consensus.after_turn` ↑ ou ↓ conforme paciência desejada.

### Update behavioral rules

- Adicione novos `do`/`dont` conforme observa novos modos de falha.
- Atualize `anti_patterns` com os bugs encontrados.

---

## Critério de pronto

A simulação está pronta quando:

1. Roda 25 turnos sem quebra de personagem.
2. Chega num `outcome` previsto ou usa o `fallback` de forma sensata.
3. Cobre os 4-5 modos de falha conhecidos do cenário (testados explicitamente).
4. Post-Simulation Report é acionável (3 next-time actions concretas).

Se algum desses 4 falhou: itere antes de declarar pronto.
