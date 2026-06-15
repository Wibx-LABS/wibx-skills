# 00 — Visão geral: o workflow 12 etapas

> Adaptado da metodologia de Andrea Ridi (*AI GPT Universe — Lesson #10: Building an AI Negotiation Simulation*, 2025), reescrito aqui com schemas explícitos e gates de PRISMA.

---

## As 12 etapas

```
1.  Prepare Story Board          ←  cenário, atores, tensão (3 ATC)
2.  Remember the Framework       ←  6 componentes nucleares
3.  Craft Synthetic Personas     ←  uma por participante
4.  Create Speaking Balance      ←  turn-taking, pesos, fases
5.  Create Response Structure    ←  formato de cada resposta
6.  Create Group Dynamics        ←  interação, coalizões, ping-pong
7.  Create Behavioral Guidelines ←  do/dont global e por persona
8.  Create Decision Logic        ←  outcomes, vetos, scores
9.  Double Check Files           ←  todos os 8 presentes?
10. Open AI Studio Build         ←  destino: aistudio.google.com (ou equivalente)
11. Load Files + Master Prompt   ←  drag, drop, prompt, build
12. Test, Debug, Refine          ←  iterar até cobrir modos de falha
```

---

## Os 6 componentes nucleares

| Componente | Pergunta que responde | Arquivo |
|---|---|---|
| **A. Persona Definitions** | Quem está na sala? | `persona_<N>.json` |
| **B. Speaking Balance** | Quem fala quando, quanto, em qual fase? | `speaking_balance.json` |
| **C. Response Structure** | Que formato cada resposta tem? | `response_structure.json` |
| **D. Group Dynamics** | Como as personas interagem entre si? | `group_dynamics.json` |
| **E. Behavioral Guidelines** | O que cada persona deve e não deve fazer? | `behavioral_guidelines.json` |
| **F. Decision Logic** | Como a simulação chega a um veredito? | `decision_logic.json` |

Mais 2 arquivos suporte:

- **Story Board** (`story_board.md`) — o palco e o roteiro de fundo.
- **Master Prompt** (`master_prompt.md`) — o prompt único que monta a simulação.

Total: **8 arquivos**.

---

## Detalhamento de cada etapa

### Etapa 1 — Story Board

**Saída:** `story_board.md`

Use o framework **3 ATC**:

- **A — Atores**: quem está na sala, quem está fora mas afeta a cena.
- **T — Tensão**: qual o conflito central, qual a "bomba relógio" escondida.
- **C — Contexto**: o que aconteceu antes, qual o estado financeiro/político/emocional da cena.

Guia detalhado em `01_story_board_guide.md`.

### Etapa 2 — Lembrar o framework

Não é uma etapa de output. É um momento de checagem mental: você está cobrindo os 6 componentes nucleares? Se sim, prossiga. Se vai pular um, pare.

### Etapa 3 — Personas

**Saída:** uma `persona_<N>.json` por participante da cena.

- Caminho preferido: **rode o pipeline single-persona** (`01_pipeline_synthetic/`) para cada uma, com evidência real.
- Caminho fallback: use o `templates/persona_general.template.json` e preencha com base no Story Board. **Declare** como sintética sem âncora.

Cada persona usa o schema `01_pipeline_synthetic/schemas/persona.schema.json` (o mesmo do pipeline single-persona).

### Etapa 4 — Speaking Balance

**Saída:** `speaking_balance.json`

Define:

- Peso de cada persona (probabilidade de falar quando o turno é "livre").
- Mínimo e máximo de turnos por rodada.
- Máximo de turnos consecutivos (anti-monólogo).
- Quem pode interromper, em quais situações.
- Fases da simulação (ex.: "Interrogation" turnos 1-10, "Negotiation" turnos 11-25) com `weight_overrides`.
- Regras de ativação por tópico (`topic:valuation` → ativa Alex).
- Fairness (máx turnos sem falar).

Use o prompt em `prompts/04_create_speaking_balance.prompt.md`.

### Etapa 5 — Response Structure

**Saída:** `response_structure.json`

Define:

- Estrutura de cada bloco de persona (header, message, body_language, energy_level, emotional_tone, references_to_others).
- Bloco de status (acordos, desacordos, tensões abertas, perguntas em aberto).
- Bloco de "próximo movimento" para o usuário (sugestões táticas, decision checkpoint, confidence level).
- Ordem das seções, separadores, prefixos.
- Schema machine-readable opcional (`decision_hint`, `top_risks`, `top_opportunities`).

Use `prompts/05_create_response_structure.prompt.md`.

### Etapa 6 — Group Dynamics

**Saída:** `group_dynamics.json`

Define:

- Tipos de interação permitidos (agreement, disagreement, challenge, build_on, clarify, reframe).
- Padrões textuais para cada tipo (com placeholders).
- Regras de conflito (`encourage_productive_conflict`, `max_conflict_intensity`).
- Regras de alinhamento pós-disputa.
- Turn-taking e interrupções.
- Coalizões permitidas.
- Repair moves quando o conflito esquenta demais.
- `ping_pong_rules` (máx back-and-forth entre par + ação quando excedido).

Use `prompts/06_create_group_dynamics.prompt.md`.

### Etapa 7 — Behavioral Guidelines

**Saída:** `behavioral_guidelines.json`

Define:

- `global_do` / `global_dont` — válido para todas as personas.
- `persona_specific_rules` — do/dont por persona individual.
- `tone_constraints` — registro geral + boundaries de humor.
- `adaptation_rules` — como adaptar ao nível de expertise do usuário (beginner/advanced).
- `anti_patterns` — comportamentos a evitar.
- `evidence_norms` — preferir dados do usuário a estatísticas genéricas; pedir exemplo concreto após N turnos.
- `user_state_adaptation` — detectar overwhelm e responder.

Use `prompts/07_create_behavioral_guidelines.prompt.md`.

### Etapa 8 — Decision Logic

**Saída:** `decision_logic.json`

Define:

- `min_turns_before_decision`, `max_turns`.
- `outcomes` — lista de vereditos possíveis (ex.: "Term Sheet Issued", "Hard Pass", "Deep Diligence") com `conditions` cada.
- `veto_rules` — quem pode vetar, qual padrão textual usar.
- `decision_trigger_rules` — checar decisão a cada N turnos, perguntar ao usuário se está pronto.
- `final_output_structure` — formato do veredito final.
- `evaluation_dimensions` — eixos numéricos avaliados (`0-10`).
- `min_scores_for_approval` — gatekeeper numérico.
- `fallback_if_no_consensus` — o que fazer se chegar no `max_turns` sem decisão.

Use `prompts/08_create_decision_logic.prompt.md`.

### Etapa 9 — Double Check

Verifique:

- [ ] Story Board presente
- [ ] N persona files presentes (N = personas na cena)
- [ ] speaking_balance.json
- [ ] response_structure.json
- [ ] group_dynamics.json
- [ ] behavioral_guidelines.json
- [ ] decision_logic.json
- [ ] master_prompt.md

Total = N + 7 arquivos (mínimo 8 se N=1, mais comum 9 se N=2).

### Etapa 10 — Abra o build target

- **Google AI Studio**: `aistudio.google.com` → Build
- **Claude Console**: console.anthropic.com → Workbench → criar prompt
- **GPT customizado**: chat.openai.com → My GPTs → Create

Guias em `deploy/`.

### Etapa 11 — Load files + Master Prompt

Faça upload dos N+7 arquivos. Cole o `master_prompt.md` na área de prompt. Press Build.

### Etapa 12 — Test, debug, refine

Use checklist em `prompts/12_test_debug_refine.prompt.md`:

- Persona authenticity e consistência
- Response timing e fluxo
- AI Hint System (quando o usuário trava, dica direcional?)
- Post-simulation grading
- Edge cases

Itere até cobrir modos de falha conhecidos.

---

## Quando você terminou

A simulação está pronta para uso quando:

1. Roda 25 turnos sem nenhuma persona quebrar personagem.
2. Chega num dos `outcomes` previstos em `decision_logic.json` (ou usa o fallback de forma sensata).
3. Cobre os 4-5 modos de falha conhecidos do cenário (você os testou explicitamente).
4. O Post-Simulation Report é acionável: aponta o que o usuário fez bem, o que fez mal, e o que tentar diferente.
