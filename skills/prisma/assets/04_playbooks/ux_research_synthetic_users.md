# Playbook: UX research com usuários sintéticos defensáveis

> **Caso de uso:** Você é PM/designer/UX researcher e quer testar um fluxo, mensagem, ou conceito **antes** de gastar tempo de usuário real. Quer um painel sintético que reage de forma **defensável**, não com viés do criador do produto.

> **Limite ético:** usuário sintético **não substitui** pesquisa real. Substitui a primeira rodada de "valida se a ideia é claramente ruim" — e libera tempo de usuário real para as perguntas que importam.

> **Tempo total:** 4-6 horas de prep. Sessão dura 20-40 min.

---

## Setup

### Passos

1. **Defina o segmento real** que você quer simular. Não use "usuário genérico". Use: "trial users do plano free que cancelaram antes do dia 14, segmento SMB B2B SaaS, US".
2. **Construa Evidence Pack** para 2-3 representantes desse segmento:
   - Idealmente: usuários reais que deixaram review pública (G2, Capterra, Reddit, X).
   - Mínimo 10 posts/reviews + 10 comentários cada.
   - Marque `status: "individual"` se forem reais; `synthetic_no_anchor` se você está inferindo do segmento.
3. **Rode o pipeline single-persona** para cada um.
4. **Story Board**:
   - Cenário: usuário acessa [feature/fluxo] pela primeira vez
   - Atores presentes: usuário(s) sintético(s)
   - Tensão: o gap entre o que o usuário **acha** que o produto faz e o que ele **realmente** faz no primeiro toque
   - Contexto: onboarding state, expectativas vindas da landing page, tarefa que ele está tentando fazer
5. **Group dynamics**:
   - `allowed_interaction_types`: `["surface_confusion", "verbalize_expectation", "ask_for_help", "abandon"]`
   - Usuário sintético deve **verbalizar pensamento** ("Por que esse botão tá aqui? Achei que fosse pra…")
6. **Behavioral guidelines**:
   - `global_do`: ["Verbalize confusion when it happens", "Try to complete the task as a real user would", "Ask for help only after 2 failed attempts"]
   - `global_dont`: ["Pretend to understand when you don't", "Suggest design fixes (you're a user, not a designer)", "Compare to competitors unprompted"]
7. **Decision logic**:
   - Outcomes: `["Task Completed Successfully", "Task Completed With Friction", "Task Abandoned", "Asked for Help"]`
   - `evaluation_dimensions`: `time_to_complete`, `confusion_count`, `confidence_at_end`, `nps_implied`
8. **Deploy + rode**.

---

## Como conduzir a sessão

Você (PM/designer) joga o papel do **produto**, não do facilitador. Cada interação é:

1. Você descreve o que o usuário vê na tela ("Você acaba de logar e vê uma tela com 4 cards: 'Conectar dados', 'Criar dashboard', 'Convidar time', 'Ver exemplos'").
2. Persona sintética verbaliza pensamento e ação ("Acabei de cadastrar — eu quero ver um exemplo primeiro pra entender o que esse produto faz. Vou clicar em 'Ver exemplos'.").
3. Você descreve o que acontece ("Você é levado para uma página com 8 exemplos por indústria, mas só 2 são interativos.").
4. Persona reage.

Repita até `decision_logic.outcomes` disparar.

---

## O que esperar como output

Após cada sessão, o Post-Simulation Report deve trazer:
- Pontos de fricção verbalizados (literais — copie a frase).
- Suposições do usuário que o produto quebrou.
- Momentos de abandono (se ocorreram).
- Implied NPS (de 0-10) com justificativa.

---

## Critério de pronto da rodada de pesquisa sintética

Você terminou a fase sintética quando:
- Identificou **pelo menos 3 fricções consistentes** entre os 2-3 usuários sintéticos.
- Tem hipóteses concretas de redesign (não "melhorar onboarding" — sim "mover o card 'Ver exemplos' para o topo e tornar os 8 exemplos interativos").
- Está pronto para a próxima rodada com **usuários reais** focada nas hipóteses (não em descoberta livre).

---

## Modos de falha conhecidos

| Falha | Causa | Como evitar |
|---|---|---|
| Personas sintéticas elogiam tudo | Falta `evidence_norms` que force fricção | Adicione `global_do: ["Verbalize confusion when it happens"]` + `anti_patterns: ["Skipping over moments of doubt"]` |
| Sessão vira "design crítico" | Personas começam a sugerir UI changes | Reforce `global_dont: ["Suggest design fixes — you are a user, not a designer"]` |
| Personas sintéticas substituem real users | Você pulou a pesquisa real | NUNCA. Use sintético para *eliminar* hipóteses ruins, não para *validar* hipóteses boas. |
| Outcomes não rastreáveis | Falta `evaluation_dimensions` numéricos | Force: `time_to_complete`, `confusion_count`, `nps_implied` |

---

## Limites éticos não-negociáveis

- **Não use** persona sintética baseada em pessoa real identificável sem consentimento, mesmo que o objetivo seja "só testar internamente".
- **Não apresente** insights de pesquisa sintética como se fossem pesquisa real. Sempre rotule: *"Insights de painel sintético — pendente validação com 5 usuários reais."*
- **Não tome decisão de produto $$$** apenas com sintético. Use para descartar hipóteses ruins e formular as boas; valide as boas com humanos.

---

## Variações

- **Concept test de landing page**: persona sintética lê o copy e verbaliza o que entendeu / o que ainda não está claro.
- **Pricing page test**: persona sintética avalia a tabela e verbaliza "qual plano eu escolheria e por quê".
- **Email campaign test**: persona sintética recebe o email, verbaliza decisão de abrir, clicar, deletar.
