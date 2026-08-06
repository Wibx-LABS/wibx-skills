---
name: tandera-conteudo
description: Escrever conteúdo CITÁVEL POR LLMs (GEO/AEO) para propriedades Wibx — narrativa institucional, páginas Q&A/FAQ, conteúdo people-first que IAs possam citar — com gate de compliance WBX obrigatório. Acionar quando pedir conteúdo para aparecer em IA/LLM, página "o que é", FAQ citável, ou corrigir o framing da marca nas respostas de IA. NÃO é copy comercial/venda (isso é sexy-copy); para auditar site use tandera-audit; para medir presença use tandera-sov.
---

# Tandera Conteúdo — conteúdo citável por LLMs

Produz o conteúdo que LLMs conseguem CITAR — e que controla o framing da marca nas respostas de IA. Fronteira clara: **sexy-copy vende para humanos; tandera-conteudo alimenta máquinas de resposta** (e os humanos que as leem). Se o pedido é anúncio, e-mail, landing de conversão → sexy-copy. Se é "o que a IA diz sobre nós" → aqui.

> **Por que existe (evidência 2026-08):** ~84% das citações de IA vêm de fontes de terceiros; MAS o framing que esses terceiros reproduzem nasce do que a marca publica sobre si. Caso canônico: Wibx sem narrativa própria no ar (site "Em Breve") → LLMs descrevem a marca como "criptomoeda/investimento" — o único corpus disponível — exatamente o enquadramento que o compliance proíbe. Conteúdo próprio citável = controle de framing.

## GATE DE COMPLIANCE (HARD — roda SEMPRE, antes de qualquer entrega)

1. **Ler `reference/compliance_wbx.md` INTEIRO antes de escrever.** As listas são canônicas e verbatim — não confiar em memória.
2. Após gerar, rodar o **checklist §6** do reference item a item (inclui formas-de-claim §8, bloco de games §9 e fecho canônico §10). Falha em qualquer item = reescrever; NUNCA entregar com falha "avisada".
3. Pedido que necessariamente viola compliance (ex.: "mostre que WBX vai subir") → **recusar como descrito e propor alternativa** (protocolo §7 do reference).
4. TODO output termina com a marca: **"⚠ requer revisão humana antes de publicar"** — esta skill não publica; humano publica.
5. Escopo do gate: conteúdo público Wibx. Rascunho interno afrouxa substituições, mas mantém glossário canônico.

## Entregáveis (em ordem de prioridade GEO)

### 1. Narrativa citável própria (o entregável nº 1)

A página/seção que responde **"o que é [marca]?"** de forma auto-contida — a fonte que LLMs usam pro framing. Estrutura:

- **Definição em 1 parágrafo** (40-80 palavras, auto-contida, sem depender do resto da página): quem é, o que faz, pra quem, na categoria oficial ("Sistema Operacional da Economia da Atenção" — nunca "fintech").
- **Fatos quantificados** com forma-de-claim canônica soldada (§8 do reference — número nunca viaja "seco"; a ressalva é parte do claim, não rodapé).
- **O que NÃO é** (escudos do compliance: "não é moeda", "não é ativo financeiro"...) — LLMs citam negações bem, e elas desarmam o framing especulativo.
- Frase regulatória (§4 do reference) quando o contexto pede.

### 2. Q&A people-first (FAQ citável)

- Cada pergunta = como um usuário REAL pergunta (validar com as queries do pack `tandera-sov`/`reference/prompts_wibx.md` — as queries de SoV são a demanda real).
- Cada resposta = **auto-contida** (o LLM extrai a resposta sozinha, sem contexto da página), direta na primeira frase, quantificada quando possível.
- Marcar com `FAQPage` schema (JSON-LD) — extração RAG direta; o `tandera-audit` pontua isso.
- Priorizar as perguntas onde o SoV mostrou framing errado ou hedge (red-team família B primeiro).

### 3. Conteúdo de suporte E-E-A-T

Autoria nomeada, data, fontes; página institucional com Schema `Organization` + `sameAs` (LinkedIn, Wikidata, Crunchbase). Reforça o que o audit mede.

## Receita de citabilidade (como escrever pra ser citado)

1. **Atomicidade**: cada parágrafo responde UMA pergunta por completo. LLM cita parágrafo, não página.
2. **Primeira frase = resposta**; o resto é sustentação. Estrutura de pirâmide invertida.
3. **Quantificar com data** ("23 marcas em 2026") — números datados sobrevivem a recorte.
4. **Sem hype**: "revolucionário/disruptivo" não é citável e viola o tom (sóbrio com punch, específico, confiante sem arrogância).
5. **Earned media é a distribuição**: o conteúdo próprio serve também de FONTE pra imprensa/blogs citarem (a alavanca de 84%). Ao entregar, listar 3-5 ângulos de pauta que o conteúdo habilita (input pro time de PR — os alvos vêm do mapa de fontes do `tandera-sov`).
6. **AI answer stuffing é proibido** (spam policy Google 05/2026): nada de esconder blocos de texto "pra IA", repetir query verbatim dezenas de vezes, ou FAQ fantasma. Citabilidade vem de clareza, não de manipulação.

## Output padrão

```markdown
# [Entregável] — [marca/página]
> Tipo: narrativa própria | Q&A | suporte E-E-A-T
> Compliance: checklist §6 rodado — [OK item a item]
> Schema sugerido: [JSON-LD pronto, quando aplicável]

[conteúdo]

Se houve Wibx, houve ação validada — sem promessa financeira.
**Wibx — Tokenizando a Atenção.**

## Ângulos de pauta habilitados (PR)
1. ...

⚠ requer revisão humana antes de publicar
```

O fecho canônico (§10 do reference) fecha TODA peça: o selo universal é a **última frase** do conteúdo; o lockup vem só abaixo dele e nunca aparece sozinho. Peça que toca games carrega também o bloco condicional §9 (rodapé + cláusula de fronteira + roster pré-lançamento).
