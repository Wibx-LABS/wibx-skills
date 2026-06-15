# 01 — Guia do Story Board (framework 3 ATC)

> O Story Board é o palco da simulação. Ele responde a três perguntas: **quem está aqui?**, **qual a tensão central?**, **o que aconteceu antes?**

---

## O framework 3 ATC

### A — Atores

Liste **todos** os atores relevantes, indicando:

- Quem está **fisicamente na cena** (vai ser uma persona ativa).
- Quem está **fora mas afeta a cena** (não vira persona, mas é mencionado).
- Quem é o "objeto da simulação" — o personagem que o usuário humano vai jogar.

Para cada ator presente na cena, descreva:

- Nome e função.
- Background (≤3 linhas).
- Estado emocional atual (não inventado — derivado do contexto).
- Posição na hierarquia da cena (quem responde a quem).

Para atores fora da cena, indique apenas o nome, função e por que importam.

### T — Tensão

Descreva a tensão central da cena com:

- **A "bomba relógio" escondida** — o fato que ainda não está na mesa mas vai estourar (ex.: promessa verbal de equity não papelada).
- **O gap explícito** — a diferença declarada entre partes (ex.: founder quer $10M, VC oferece $6M).
- **Os push factors** de cada lado.
- **O custo de não chegar a acordo** para cada lado.

A tensão não pode ser "as partes precisam negociar". Ela precisa ser uma diferença específica, com data limite ou consequência rastreável.

### C — Contexto

Descreva o estado da cena no momento de abertura:

- **Financeiro** (se aplicável): runway, MRR, burn rate, cash on hand.
- **Operacional**: o que está rodando, o que está travado, quem reporta a quem.
- **Político**: quais alianças existem, quais conflitos latentes.
- **Temporal**: quanto tempo até o próximo gatilho externo (próxima reunião com LP, próximo board, próxima rodada).

---

## Estrutura recomendada do `story_board.md`

```markdown
# Story Board — <Nome da simulação>

## Cenário (1 parágrafo)
<Descrição em 5-8 linhas do que está acontecendo.>

## Empresa / Organização envolvida
- Modelo de negócio
- Tração atual
- Equipe interna

## Atores
### Presentes na cena
- **<Nome> (<função>)** — <background curto, estado emocional>

### Fora da cena, mas relevantes
- **<Nome> (<função>)** — <por que importa>

## Tensão central
### A bomba relógio
<O fato escondido que vai estourar.>

### O gap explícito
<A diferença declarada entre partes.>

### Push factors
- Lado A: <…>
- Lado B: <…>

### Custo de não-acordo
- Lado A: <…>
- Lado B: <…>

## Contexto financeiro/operacional
<MRR, burn, runway, tração, pipeline.>

## Contexto político
<Alianças, conflitos latentes.>

## Janela temporal
<Quanto tempo até o próximo gatilho externo.>

## Mistakes do "estudante" (opcional)
<Erros típicos que o personagem-objeto cometeu antes da cena começar, que serão expostos durante a simulação.>

## Blind spots do "estudante"
<O que ele não sabe que não sabe, que a simulação vai revelar.>
```

---

## Anti-padrões do Story Board

| Anti-padrão | Por que é problema | Como corrigir |
|---|---|---|
| "Os atores vão discutir o futuro da empresa" | Tensão genérica. Não tem bomba relógio. | Especifique: "Os atores precisam decidir hoje sobre X específico, sob pressão de Y prazo." |
| Personas com motivação inventada | Quebra o axioma de evidência | Cada motivação precisa rastrear para `persona.json` correspondente |
| Atores demais (>4 ativos) | Dilui o foco, dificulta speaking_balance | Limite a 2-4 personas ativas; o resto fica fora da cena |
| Contexto sem números | Impossibilita decision_logic baseado em scores | Inclua pelo menos 3 métricas verificáveis |
| Sem custo de não-acordo | Simulação não tem pressão temporal | Sempre adicione consequência rastreável de não-decisão |

---

## Exemplo (resumido)

Veja `03_examples/nutriloop_negotiation/story_board.md` para um exemplo completo end-to-end.

Resumo desse exemplo:

- **Atores presentes**: Martina (founder, jogada pelo usuário), Alex (VC bad cop), Dan (VC good cop)
- **Atores fora**: Kevin (COO), Asha (CTO) — mencionados, fonte da bomba relógio
- **Tensão**: 20% de equity prometida verbalmente a Kevin/Asha (bomba relógio) + gap de valuation $10M vs realidade $6M
- **Contexto**: MRR $52K, burn $160K, runway 6.5 meses, 3 patentes provisórias, conflito CTO-COO em escalada
- **Janela temporal**: precisa fechar seed em ≤2 meses ou perder Kevin/Asha
