# Playbook: Simulação de entrevista de hiring

> **Caso de uso:** Você é hiring manager ou candidato. Quer simular a entrevista real antes dela acontecer — com personas defensáveis dos entrevistadores (ou do candidato), comportamento previsível, e veredito final acionável.

> **Tempo total:** 3-6 horas de preparação. Simulação dura 30-60 min cada rodada.

> **Saída esperada:** simulação multi-agente rodando em AI Studio / Claude / GPT, com Post-Interview Report estruturado.

---

## Variante A — Candidato treinando para entrevista

### Setup

Você é o candidato. Vai entrevistar com 2-3 pessoas:
- Hiring manager (decisor)
- Tech lead ou peer (avalia capacidade técnica)
- Recruiter (avalia fit cultural, motivação)

### Passos

1. **Para cada entrevistador, monte um Evidence Pack** com base no LinkedIn público + posts + entrevistas em podcast. Mínimo: 10 posts + 10 comentários cada.
2. **Rode o pipeline single-persona** para cada um (`01_pipeline_synthetic/`). Saída: 1-3 `persona.json`.
3. **Escreva o Story Board** (`02_pipeline_simulation/01_story_board_guide.md`) com:
   - Cenário: entrevista de [posição] para [empresa]
   - Atores presentes: entrevistadores + você (candidato)
   - Tensão: o "gap" entre a sua experiência atual e o que a posição exige
   - Bomba relógio: o ponto fraco do seu CV que você prefere não tocar
   - Contexto: estágio da empresa, urgência da contratação, alternativas no pipeline deles
4. **Gere os 6 arquivos de orquestração** usando os prompts em `02_pipeline_simulation/prompts/`. Calibrações específicas:
   - `speaking_balance`: hiring manager 0.5, tech lead 0.3, recruiter 0.2 (típico).
   - `decision_logic.outcomes`: `["Strong Yes", "Soft Yes", "No-Hire", "Need More Signal"]`.
   - `evaluation_dimensions`: `culture_fit`, `technical_depth`, `motivation_clarity`, `compensation_alignment`.
5. **Deploy** num dos 3 (AI Studio / Claude / GPT).
6. **Rode 2-3 vezes**, mudando de estratégia. Anote em que ponto cada estratégia trava ou flui.

### Critério de pronto

Você está pronto para a entrevista real quando:
- Conseguiu o veredito `Strong Yes` em pelo menos 1 rodada.
- Entendeu **por quê** as outras rodadas chegaram em `Soft Yes` ou `No-Hire`.
- Tem 3 next-time actions concretas para cada falha observada.

---

## Variante B — Hiring manager calibrando processo

### Setup

Você é hiring manager. Quer:
- Treinar entrevistadores juniores num cenário controlado.
- Calibrar viés do painel.
- Testar perguntas novas antes de usar em candidato real.

### Passos

1. **Monte o Evidence Pack do candidato hipotético** (ou de um candidato real que você já entrevistou e tem permissão de usar como exemplo).
2. **Construa a persona do candidato** via pipeline single-persona.
3. **Construa as personas dos entrevistadores** — usando você mesmo + colegas (consentimento documentado).
4. **Story Board**: entrevista de painel para [posição]. Tensão: candidato é "borderline" — alguns sinais fortes, alguns sinais de alerta.
5. **Decision logic**: outcomes `["Strong Hire", "Hire", "No-Hire", "Conflicted Panel"]`. Veto rules: cada entrevistador tem veto se score `culture_fit < 6`.
6. **Behavioral guidelines** para os entrevistadores: `do: ["Use STAR method", "Probe with concrete examples", "Surface concerns explicitly"]`; `dont: ["Ask leading questions", "Compare to other candidates verbalmente"]`.
7. **Deploy + rode** com seus entrevistadores juniores como "candidato" da simulação. Eles experimentam o lado oposto.

### Critério de pronto

O processo está calibrado quando:
- Mesmas perguntas + mesmo candidato hipotético → mesma decisão final em 3 rodadas independentes.
- Os entrevistadores conseguem articular *por quê* chegaram naquela decisão usando os `evaluation_dimensions` declarados.
- Os modos de "Conflicted Panel" aparecem nos casos certos (candidato genuinamente borderline) e não nos casos errados (viés individual de um entrevistador).

---

## Modos de falha conhecidos

| Falha | Causa | Como evitar |
|---|---|---|
| Personas dos entrevistadores são "genéricas tech" | Falta evidência pessoal específica | Não pule a coleta. Use mínimo 10 posts cada. |
| Simulação aprova todo mundo | `min_scores_for_approval` baixo demais | Eleve thresholds, especialmente em `culture_fit` |
| Simulação rejeita todo mundo | `veto_rules` ativam fácil demais | Revise o threshold de `concern` vs `blocker` |
| Candidato simulado quebra personagem | `behavioral_guidelines.global_dont` não enfatizou character maintenance | Reforce no master_prompt: "Em hipótese alguma quebre personagem" |
| Post-Interview Report é vago | `final_output_structure` não exige itens concretos | Force: 3 next-time actions específicas, com verbo + objeto |

---

## Variações

- **Pair programming simulado**: combine com tool use (Code Interpreter) para o "tech lead" propor problema real e avaliar a abordagem.
- **Reference call simulada**: persona única (ex-gestor do candidato) + você. Treina a habilidade de extrair sinais sem viés de cortesia.
- **Compensation negotiation**: foco em `decision_logic.outcomes` financeiros (`Offer Accepted`, `Counter Pending`, `Walked Away`).
