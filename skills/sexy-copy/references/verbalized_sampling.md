# Verbalized Sampling aplicado a copy — modo híbrido

Verbalized Sampling (VS) é uma técnica de prompting introduzida por Zhang et al. (2024–2025, "How to Mitigate Mode Collapse in LLMs by Verbalizing Probability Distributions"). A ideia central: LLMs em modo padrão convergem para a resposta de maior probabilidade percebida (mode collapse) mesmo quando o espaço de soluções boas é amplo. Pedir ao modelo que **verbalize uma distribuição de probabilidade sobre múltiplas candidatas** disciplina diversidade real e amplia o espaço explorado.

Esta skill implementa VS em **dois sub-modos**: uma **adaptação pragmática** (default) e a **forma canônica do paper** (quando o usuário pede explicitamente).

---

## Quando usar cada sub-modo

### Sub-modo 1 — Adaptação pragmática (DEFAULT)

Use por padrão. É o que dispara automaticamente em qualquer pedido de copy.

**Como funciona**:
- Você escolhe **uma** recomendada (sua melhor aposta dado o briefing)
- Gera **3 alternativas** em ângulos substantivamente diferentes
- Para cada alternativa, atribui uma probabilidade verbalizada de **superar a recomendada** no contexto descrito
- Articula em **quando** cada alternativa beats a recomendada

**Probabilidades não somam 100%** — cada alternativa é avaliada contra a recomendada, não entre si.

**Por que adaptado**: em copy, "qualidade absoluta" é mal-definida (depende do canal, momento, leitor). Calibrar contra uma recomendada explícita é mais útil pra decisão prática: o usuário escolhe entre "ficar com a recomendada" ou "trocar pela alt X num cenário específico".

**Trade-off**: não é fiel à literatura. É uma adaptação que troca rigor por usabilidade.

### Sub-modo 2 — VS canônico (ESTRITO)

Use **apenas** quando o usuário pedir explicitamente. Triggers:

- "modo VS estrito"
- "verbalized sampling canônico"
- "VS do paper"
- "amostragem verbalizada canônica"
- "distribuição completa de probabilidade"
- "modo VS rigoroso"
- "VS fiel ao paper"

**Como funciona**:
- Você gera **N candidatas** (default N=5, ou conforme pedido) em ângulos genuinamente diferentes
- Para cada candidata, atribui probabilidade absoluta **p_i** que representa a qualidade percebida sobre o espaço total de respostas
- As probabilidades **somam ~1.0** (ou ~100%)
- Nenhuma candidata é destacada como "recomendada" — todas têm peso explícito
- Probabilidades altas (>0.3) indicam alta confiança nessa direção; cauda (5-15%) representa explorações de baixa probabilidade mas alta variância

**Output format**:
```
## Candidatas (N=5, probabilidades absolutas, soma ≈ 1.0)

**1.** (p = 0.32) [copy]
> Ângulo: [rótulo do framework/ângulo]

**2.** (p = 0.24) [copy]
> Ângulo: [rótulo]

**3.** (p = 0.20) [copy]
> Ângulo: [rótulo]

**4.** (p = 0.14) [copy]
> Ângulo: [rótulo]

**5.** (p = 0.10) [copy]
> Ângulo: [rótulo]

> Soma: 1.00. Diversidade verificada em eixo: [eixo]
```

**Quando faz sentido o modo estrito**:
- Pesquisa de copy / brainstorming sistemático onde nenhuma direção deve ser anchored cedo
- Quando o usuário quer ver explicitamente a "distribuição de qualidade percebida" da skill
- Comparações entre versões de skill (mesmo briefing, ver como as probabilidades se distribuem)
- Casos onde a noção de "recomendada" é prematura (briefing ambíguo, mercado novo)

**Quando NÃO usar o estrito**:
- Pedido padrão de copy de produção (a adaptação serve melhor)
- Pedidos micro (botão, slogan curto) — overhead injustificado
- Quando o usuário quer decisão rápida, não exploração

---

## Regra de diversidade obrigatória (ambos sub-modos)

Em qualquer sub-modo, as candidatas precisam diferir em pelo menos **um eixo substantivo**:

- **Ângulo / Big Idea** (problem-led, promise-led, story-led, secret-led, identity-led)
- **Framework de estrutura** (AIDA, PAS, BAB, FAB, HSO, StoryBrand)
- **Nível de consciência alvo** (problem-aware → most-aware spectrum)
- **Tom dominante** (sóbrio, provocativo, empático, autoridade)

Se A, B, C, D, E são apenas reescritas com sinônimos = falha, refaça.

No modo estrito, com N=5, é normal cobrir 3-5 eixos diferentes (mais espaço pra diversidade).

---

## Calibração de probabilidades

### Sub-modo 1 (adaptação)

Calibração das alternativas (chance de superar a recomendada):

- **50%+** — alt é virtualmente equivalente, escolha por preferência
- **30-50%** — alt beats recomendada em sub-contextos específicos
- **15-30%** — alt é aposta com upside maior se contexto permite
- **5-15%** — alt é fallback se recomendada falhar com este avatar
- **<5%** — não deveria estar entre as alternativas

**Anti-padrão**: distribuir 35%/30%/25% pra ficar "balanceado". Esconde sinal. Se a recomendada está bem alinhada ao briefing, as alts ficam tipicamente entre 5% e 25%.

### Sub-modo 2 (canônico, soma ≈ 1.0)

Calibração das probabilidades absolutas:

- **0.30-0.45** — direção principal, alta confiança que é boa
- **0.20-0.30** — direção secundária forte, alternativa robusta
- **0.10-0.20** — direção exploratória ainda razoável
- **0.05-0.10** — cauda da distribuição, swing pra contextos atípicos
- **<0.05** — não deveria estar na lista, está fraca

**Anti-padrão no canônico**: distribuição uniforme (0.20/0.20/0.20/0.20/0.20). Indica que o modelo não diferenciou candidatas — defeito de calibração. Boa distribuição tem moda visível.

**Anti-padrão oposto**: distribuição muito spike (0.80/0.05/0.05/0.05/0.05). Indica que o modelo só gerou 1 candidata real + 4 enchimentos. Refazer.

---

## Exemplo de output em cada sub-modo

**Briefing**: Tagline curta para apresentação WIBX LABS, público diretoria interna.

### Sub-modo 1 — Adaptação (default)

**Recomendada**: *"LABS — antes do sistema, a inteligência."*
*(ângulo identity-led, sofisticação 5, voz Olho de Tandera)*

**Alternativas**:
- *"LABS — onde o experimento vira infraestrutura."* (prob 21%, ângulo função/mecanismo) — melhor se a apresentação enfatiza handoff técnico
- *"LABS — inteligência operacional aplicada."* (prob 14%, ângulo formal) — melhor para slide-título sóbrio
- *"LABS — o setor que valida antes de escalar."* (prob 10%, ângulo princípio operacional) — melhor se a fala explica método

### Sub-modo 2 — Canônico (estrito)

**Candidatas (N=5, soma ≈ 1.00)**

**1.** (p = 0.34) *"LABS — antes do sistema, a inteligência."*
> Ângulo: identity-led, voz aspiracional sóbria

**2.** (p = 0.24) *"LABS — onde o experimento vira infraestrutura."*
> Ângulo: função/mecanismo, voz operacional

**3.** (p = 0.18) *"LABS — inteligência operacional aplicada."*
> Ângulo: descritivo formal, voz institucional

**4.** (p = 0.14) *"LABS — o setor que valida antes de escalar."*
> Ângulo: princípio operacional explícito, voz didática

**5.** (p = 0.10) *"LABS opera a inteligência. Outros escalam."*
> Ângulo: contraste/diferenciação, voz mais agressiva (fora do Olho de Tandera padrão)

> Soma: 1.00. Diversidade verificada em eixo: ângulo + voz.

---

## VS como ferramenta de auto-crítica (ambos modos)

VS não é só formato de output. É também mecanismo de auto-crítica antes de entregar.

Antes de fixar candidatas, gere mentalmente 7-10 e descarte as 2-5 piores. Para a recomendada (modo adaptado) ou para a candidata de maior probabilidade (modo canônico), pergunte: **se eu submetesse minhas candidatas a um copywriter sênior cego ao briefing, ele apontaria a mesma como melhor?**

Se não, alguma coisa no diagnóstico de Schwartz + ângulo + framework está mal calibrada. Volte para as 4 camadas (consciência, sofisticação, ângulo, framework).

---

## Quando NOT usar VS (qualquer sub-modo)

VS é overhead para pedidos triviais. Para:

- **Microcopy de botão** (5 palavras): listagem simples de 3 opções, sem probabilidades
- **Slogan único curtíssimo** (3-5 palavras): listagem de 3-5 com 1 linha de rationale, sem prob explícita
- **Push notification** (60 chars): listagem de 3, sem rationale extenso
- **Subject line**: listagem de 3-5 com 1 linha cada

Para qualquer copy de média/alta complexidade (hero, LP, sales letter, ad longo, sequência de email), VS completo se aplica.

---

## Referências (paper original)

Zhang et al., 2024–2025. "How to Mitigate Mode Collapse in LLMs by Verbalizing Probability Distributions". A ideia central que esta skill implementa em sub-modo canônico: pedir ao modelo que gere candidatas com probabilidades explícitas reduz mode collapse e aumenta diversidade de output em tarefas criativas — efeito empiricamente medido em poesia, brainstorming, geração narrativa.

A adaptação (sub-modo 1) é decisão própria desta skill, motivada pelo uso prático em copy comercial onde "qualidade absoluta" é menos útil que "qualidade relativa a uma recomendada".

---

## Resumo prático

| Aspecto | Sub-modo 1 (Adaptação, default) | Sub-modo 2 (Canônico, estrito) |
|---|---|---|
| Quando ativa | Sempre, em pedido de copy médio/longo | Quando usuário pede explicitamente |
| Estrutura | 1 recomendada + 3 alternativas | N candidatas (default 5) sem hierarquia |
| Probabilidades | "Chance de superar a recomendada" | Probabilidade absoluta, soma ~1.0 |
| Anchoring | Sim (recomendada como âncora) | Não (todas no mesmo nível) |
| Calibração esperada | 5-25% típico nas alts | Moda visível, sem distribuição flat |
| Fidelidade ao paper | Inspirado, não canônico | Canônico |
| Melhor para | Decisão rápida + opções | Exploração sistemática + brainstorming |
