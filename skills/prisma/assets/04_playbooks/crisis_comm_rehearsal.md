# Playbook: Crisis communication rehearsal

> **Caso de uso:** Sua empresa enfrenta (ou está prestes a enfrentar) uma crise pública — vazamento de dados, falha de produto, decisão impopular, declaração mal-interpretada. Você precisa ensaiar a comunicação **antes** dela acontecer ao vivo.

> **Tempo total:** 3-5 horas de prep. Cada rodada dura 30-45 min.

> **Saída esperada:** comunicado público + Q&A interno coerentes, com respostas pré-preparadas para as 5-10 perguntas mais agressivas dos jornalistas / board / funcionários.

---

## Setup

### Passos

1. **Identifique as audiências reais** que vão receber a comunicação:
   - Imprensa (jornalistas específicos que cobrem seu setor)
   - Funcionários
   - Board / investidores
   - Clientes
   - Reguladores (se aplicável)
2. **Para cada audiência, monte 1 persona representativa.** Idealmente:
   - Imprensa: jornalista real que cobre seu setor, com histórico público de coberturas críticas. Evidence Pack: artigos publicados + Twitter/X dele.
   - Funcionários: derive de pesquisas internas anônimas ou comentários em ferramenta como Blind, Glassdoor.
   - Board: stakeholder específico que tipicamente lidera reação a crise.
   - Cliente: cliente de alto valor que tem voz pública.
3. **Rode o pipeline single-persona** para cada um.
4. **Story Board**:
   - Cenário: você acaba de publicar [comunicado] sobre [crise]
   - Atores presentes: as 3-5 personas
   - Tensão: o gap entre a narrativa que você quer contar e a narrativa que vai ser percebida
   - Bomba relógio: o detalhe técnico/legal/operacional que vai ser tirado de contexto
   - Contexto: timing, cobertura paralela, próximos eventos relevantes
5. **Speaking Balance**:
   - Jornalistas costumam dominar Q&A (peso 0.4-0.5).
   - Funcionário pode falar via "town hall question" simulado.
   - Board fala via "private feedback" simulado.
6. **Behavioral Guidelines** críticas:
   - `global_do`: ["Ask the toughest version of the question", "Probe for inconsistencies between this statement and prior public statements", "Push back when the answer is corporate-speak"]
   - `global_dont`: ["Accept hedged answers", "Help the company spin"]
7. **Decision Logic**:
   - Outcomes: `["Comunicado Bem Recebido", "Comunicado Mal Recebido — Repórter Cético", "Crise Escala — Cobertura Negativa", "Funcionários Confiam", "Funcionários Perdem Confiança"]`. Não é binário — múltiplos vereditos por audiência.
   - `evaluation_dimensions`: `clarity`, `accountability_signaled`, `defensiveness_minimized`, `next_steps_credible`.
8. **Deploy + ensaie**.

---

## Como conduzir

Você (CEO ou porta-voz) joga **o papel proponente**. Você publica o comunicado, responde Q&A, reage a follow-ups. As personas reagem como reagiriam de verdade.

### Estrutura típica da sessão

1. **Você publica o comunicado** (cole o texto na simulação).
2. **Jornalistas fazem 3-5 perguntas iniciais** (mistura de informacional + cético).
3. **Você responde cada uma**.
4. **Jornalistas reagem** — alguns aceitam, alguns probam mais.
5. **Funcionário-persona faz pergunta de town hall**.
6. **Board-persona dá feedback privado** (mensagem direta).
7. **Cliente-persona reage publicamente** (post no Twitter/X simulado).
8. **Você decide se faz follow-up oficial ou deixa decantar**.
9. **Simulação avalia o estado final por audiência**.

---

## O que esperar

### Rodada 1
Seu comunicado provavelmente cai em alguma armadilha previsível:
- Linguagem corporativa que jornalistas vão recortar.
- Falta de accountability explícita.
- "Estamos investigando" sem prazo.
- Atribuição de culpa que vai voltar a te morder.

### Rodada 2
Você reescreve baseado nas falhas. Provavelmente sobe para `Comunicado Bem Recebido` por algumas audiências, mas perde outra.

### Rodada 3
Você endereça a audiência mais cética diretamente — mesmo que custe pontos com a audiência mais amigável. Provavelmente chega num resultado defensável em todas as audiências.

---

## Decision Brief para a hora real

Após terminar:

1. **A versão final do comunicado** (depois de N rounds de revisão).
2. **As 10 perguntas mais agressivas esperadas** + respostas pré-preparadas (2-3 frases cada).
3. **A linha vermelha** — o que você **não vai** dizer mesmo sob pressão.
4. **O sinal de escalada** — quando a crise piorou ao ponto de exigir Plano B (segundo comunicado, mea culpa, escalation interna).
5. **A coalizão prévia** — quem precisa estar alinhado *antes* da publicação (jurídico, comms, board, mídia amigável).

---

## Modos de falha conhecidos

| Falha | Causa | Como evitar |
|---|---|---|
| Personas-jornalista aceitam respostas evasivas | Falta `behavioral_guidelines.global_do: ["Push back when answer is corporate-speak"]` | Adicione. Force probing. |
| Personas-funcionário são "felizes corporativamente" | Persona montada a partir de pesquisa de engajamento (viés positivo) | Use Blind, Glassdoor, Reddit r/<empresa> — fontes mais cruas |
| Simulação aprova comunicado defensivo | `min_scores_for_approval.accountability_signaled` baixo | Eleve para ≥7. Accountability é o eixo mais valioso em crise. |
| Cobertura simulada é "neutra demais" | Sem persona-jornalista cético | Adicione ao menos 1 persona modelada em jornalista historicamente crítico ao setor |
| Você não muda o comunicado entre rodadas | Defensividade do autor | Force-se a revisar SEMPRE entre rodadas. Se chegar igual, está descartando os feedbacks. |

---

## Limites éticos não-negociáveis

- **A simulação é dress rehearsal**, não cobertura preditiva. Ela testa sua narrativa contra adversários sintéticos — não garante o que vai acontecer ao vivo.
- **Não use** persona sintética de jornalista real identificável para preparar "ataque" a esse jornalista. Use para preparar **a si mesmo** para a entrevista.
- **Não publique** o comunicado simulado sem revisão humana de jurídico, comms profissional, e CEO/CMO.

---

## Variações

- **Product launch crisis (post-launch)**: bug grave detectado dias após lançamento. Personas: clientes early adopters frustrados + analyst que cobre seu setor.
- **Leadership transition**: anúncio de saída de CEO ou cofounder. Personas: funcionários ansiosos + investidores + imprensa + clientes que assinaram com base na liderança.
- **Regulatory action**: você recebeu carta de regulador. Personas: jornalista do setor + advogado público + cliente regulado.
