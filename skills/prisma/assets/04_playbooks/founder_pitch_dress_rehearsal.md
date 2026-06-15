# Playbook: Dress rehearsal do pitch de founder

> **Caso de uso:** Você é founder e tem um pitch importante (investor meeting, demo day, board) em ≤14 dias. Quer ensaiar contra um painel sintético que vai perguntar **as perguntas reais**, não as perguntas educadas.

> **Tempo total:** 4-8 horas de prep. Cada ensaio dura 30-45 min.

> **Saída esperada:** simulação rodando + relatório de modos de falha do pitch atual + lista de patches a aplicar no deck antes da reunião real.

---

## Setup

Você vai construir um painel sintético com 2-3 investidores que **se parecem com os investidores reais da sua próxima reunião**.

### Passos

1. **Identifique os investidores reais** que vão estar na sala. Para cada um, capture:
   - LinkedIn público (posts + comentários, mínimo 10 cada).
   - Threads no Twitter/X se aplicável.
   - Podcasts em que ele/ela apareceu (transcrições ou notas).
   - Portfolio público (empresas investidas — sinaliza thesis).
   - Threads em fóruns como NFX/SaaStr (se aplicável).
2. **Rode o pipeline single-persona** para cada investidor (`01_pipeline_synthetic/`). Use mínimo 1 persona, ideal 2-3.
3. **Adicione 1 persona "wild card"** — um arquétipo opcional que cobre o ângulo que os investidores reais não cobrem. Ex.: se os reais são todos VCs financeiros, adicione um "operator turned angel" que vai perguntar coisas operacionais.
4. **Story Board**:
   - Cenário: investor meeting de [seed/A/B/C] round para [empresa]
   - Atores: investidores + você (founder)
   - Tensão: o gap entre o que você acha que seu deck mostra e o que ele realmente mostra
   - Bomba relógio: o slide que tem o número fraco que você prefere passar rápido
   - Contexto: stage, MRR/ARR, runway, ask, valuation alvo
5. **Behavioral guidelines** importantes:
   - `global_do`: ["Surface valuation gap explicitly", "Probe unit economics", "Ask about cap table mess"]
   - `global_dont`: ["Accept narrative without numbers", "Let founder hand-wave on burn"]
   - Por persona: copie comportamentos do `persona.json` correspondente.
6. **Decision logic**:
   - Outcomes: `["Term Sheet Likely", "Deep Diligence Required", "Pass — Insufficient Signal", "Pass — Fatal Flaw"]`
   - Veto rules: cada investidor pode vetar se `financial_discipline < 6`
   - Min turns: 8
   - Max turns: 20
7. **Deploy + ensaie**.

---

## O que esperar em cada rodada

### Primeira rodada
Você vai sangrar. Os investidores vão fazer perguntas que você não preparou. Você vai dar respostas hand-wavy. Provavelmente vai chegar em `Pass — Insufficient Signal` ou `Deep Diligence Required`.

**Não desanime — esse é o ponto.** É melhor sangrar na simulação do que na reunião real.

### Segunda rodada
Você corrige os 3-4 piores buracos da primeira. Provavelmente sobe para `Deep Diligence Required` mais limpo, ou `Term Sheet Likely` com ressalvas.

### Terceira rodada
Você ataca os modos de falha estruturais (não apenas tactical fixes). Pode envolver mexer no deck.

### Critério de pronto

Você está pronto quando:
- Conseguiu `Term Sheet Likely` em pelo menos 1 rodada.
- Sabe explicar, sem hesitar, **por quê** cada pergunta foi feita (não só "o que" foi feito).
- Tem deck v2 com 3+ slides reformulados baseados nas falhas detectadas.

---

## Modos de falha conhecidos do founder

| Modo de falha | Como a simulação revela | Patch típico |
|---|---|---|
| Deck mente sobre runway | Investidor pergunta detalhe específico do burn por categoria | Refaça slide com burn breakdown real |
| Valuation pulled out of thin air | "Como você chegou em $X pré-money?" → comparables não defensáveis | Construa comparable analysis defensável (3-5 deals públicos relevantes) |
| Cap table tem promessas verbais | Investidor pergunta diretamente "tem alguma alocação não papelada?" | Resolva ANTES do meeting — papela ou desfaz |
| Time conflict escondido | Investidor pergunta sobre dinâmica entre cofounders | Tenha narrativa honesta pronta (não é fingir que não tem) |
| Use of funds genérico | "Especifique quanto pra cada um e por quê" → answer genérico | Refaça slide com breakdown por workstream + milestone esperado |
| ARR vs MRR vs pipeline confuso | Investidor pede pra reconciliar | Tenha cohort table real, não slide bonito |

---

## Variações

- **Board meeting rehearsal**: substitua investidores por board members. Outcomes mudam: `Approval`, `Conditional Approval — Revisit Next Quarter`, `Block`.
- **Customer reference call rehearsal**: persona única (CRO de prospect). Outcomes: `Reference Strongly Positive`, `Mixed`, `Negative — Won't Help`.
- **Acquisition negotiation rehearsal**: 2 personas (M&A lead + integration lead da empresa compradora). Outcomes: `LOI Signed`, `Walked Away — Price`, `Walked Away — Terms`.
