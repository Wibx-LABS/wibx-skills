# Playbook: Sala de decisão executiva (multi-stakeholder)

> **Caso de uso:** Você precisa tomar uma decisão estratégica que envolve múltiplos stakeholders (board, C-suite, key partners). Quer ensaiar a conversa para entender onde estão as tensões, quem vai vetar, qual é o caminho mais provável de aprovação.

> **Tempo total:** 6-12 horas de prep (essa é a aplicação mais complexa de PRISMA).

> **Saída esperada:** simulação de board/exec meeting com 3-5 personas, lógica de decisão estruturada, e um Decision Brief acionável para a reunião real.

---

## Setup

### Passos

1. **Mapeie os stakeholders reais** que vão estar na sala (ou ser influenciados pela decisão). Para cada um:
   - Função na decisão (decisor, influenciador, executor, vetador).
   - Stake (o que ele ganha/perde com cada outcome).
   - Track record em decisões similares anteriores.
2. **Construa Evidence Pack** para cada um. Stakeholders C-level e board members costumam ter pegada pública suficiente. Para os que não têm:
   - Use entrevistas internas (com consentimento).
   - Use emails/Slack históricos onde a pessoa argumentou sobre decisão similar (consentimento).
   - Use `synthetic_no_anchor` com `disclosure` explícito.
3. **Rode o pipeline single-persona** para cada um. Saída: 3-5 `persona.json`.
4. **Story Board**:
   - Cenário: decisão sobre [tópico] em [contexto de tempo e pressão]
   - Atores presentes: stakeholders
   - Tensão: o trade-off central + os trade-offs secundários
   - Bomba relógio: o conflito de interesse não declarado, ou o dado que ainda não está na mesa
   - Contexto: estado financeiro, política interna, deadlines externos
5. **Speaking Balance**:
   - Pesos refletem hierarquia + voz histórica em decisões (CEO geralmente 0.3-0.4, outros distribuídos).
   - Fases: `Opening Statements` (cada um tem voz garantida) → `Cross-Examination` (perguntas cruzadas) → `Decision Push` (forçar resolução).
6. **Group Dynamics**:
   - `coalition_rules.allow_coalitions: true` — coalizões são realistas em sala C-suite.
   - `repair_moves` populados para descomprimir momentos de conflito alto.
7. **Decision Logic**:
   - Outcomes: customizados ao tipo de decisão. Ex.: `["Approved As-Is", "Approved With Conditions", "Deferred — Need More Data", "Rejected"]`.
   - **Veto rules são críticos aqui** — defina quem pode vetar e com qual padrão.
   - Min turns: 8-10 (decisões C-level não devem ser rushadas).
   - `min_scores_for_approval` distribuído entre dimensões que cada stakeholder valoriza.
8. **Deploy + rode**.

---

## Como conduzir

Você (decisor primário ou facilitador) joga **o papel proponente**. Você apresenta a decisão, sustenta a posição, responde às objeções, propõe ajustes. Os stakeholders sintéticos respondem em personagem.

Cada rodada deve durar 30-60 min de simulação.

---

## O que esperar

### Rodada 1
Você descobre 2-3 objeções que **não tinha previsto**. Provavelmente é vetado ou termina em `Deferred — Need More Data`.

### Rodada 2
Você incorpora as objeções da rodada 1. Provavelmente sobe para `Approved With Conditions` mas tem alguém ainda relutante.

### Rodada 3
Você endereça o stakeholder mais relutante diretamente — seja modificando a proposta, seja construindo coalizão antes da reunião. Provavelmente chega em `Approved As-Is` ou `Approved With Conditions` limpas.

---

## Decision Brief para a reunião real

Após terminar a simulação, compile:

1. **A decisão em 1 frase.**
2. **O outcome esperado** (baseado nas rodadas) + intervalo de confiança.
3. **Quem provavelmente apoia, quem hesita, quem veta.**
4. **As 3 objeções mais fortes** + respostas pré-preparadas.
5. **A coalizão a construir antes da reunião** (quem precisa estar do seu lado *antes* da sala oficial).
6. **Os ajustes na proposta** que aumentam a chance de aprovação sem comprometer o objetivo.
7. **O fallback** se a decisão for vetada — o que pedir na próxima rodada.

Isso é o documento de 1 página que você leva (mentalmente) para a reunião real.

---

## Modos de falha conhecidos

| Falha | Causa | Como evitar |
|---|---|---|
| Simulação aprova tudo | `veto_rules` muito permissivas + `min_scores_for_approval` baixos | Calibre os scores reais — cada dimensão precisa ter threshold defensável |
| Stakeholders sintéticos concordam demais | `conflict_rules.encourage_productive_conflict: false` ou `max_conflict_intensity: low` | Eleve para `medium` ou `high`; force `required_when_major_tradeoff: true` |
| Sem coalizão emergente | `coalition_rules.allow_coalitions: false` | Permita. Coalizões são realistas. |
| CEO domina a conversa | Peso da persona dele desbalanceado | Calibre pesos reais; CEOs costumam falar 25-35% do tempo em sala C-suite, não 60% |
| Decisão chega tarde demais | `max_turns` muito alto + `fallback` muito permissivo | Force `max_turns: 15-20` com fallback explícito |

---

## Limites éticos

- Stakeholders sintéticos **não** preveem decisões reais com certeza. Eles ajudam a explorar cenários, não a substituir conversa.
- **Não use** a simulação para "manipular" stakeholders reais (construir coalizão é legítimo; mentir sobre o que vai propor não é).
- Se a persona sintética de um stakeholder está consistentemente dizendo "isso não vai passar", **escute**. Pode ser ajuste necessário na proposta, não problema com a persona.

---

## Variações

- **Crisis comm rehearsal**: stakeholders são jornalistas, board, funcionários. Outcome: comunicado público + Q&A interno coerentes.
- **Partnership negotiation**: stakeholders incluem parceiro proposto + seu próprio C-suite. Outcomes: `Partnership Signed`, `Renegotiate`, `Walk Away`.
- **Layoff decision**: stakeholders incluem CFO, CHRO, CEO + persona "voice of remaining team". Outcomes incluem `Proceed As Planned`, `Smaller Cut`, `Defer`, `Restructure Instead`.
