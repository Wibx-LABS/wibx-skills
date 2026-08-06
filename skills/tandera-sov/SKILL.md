---
name: tandera-sov
description: Medir share of voice e presença REAL da marca em LLMs e AI search (ChatGPT, AI Overviews, Gemini, Meta AI, Perplexity, Copilot) com protocolo estatístico de runs repetidos. Acionar quando pedir para medir presença em LLMs, rodar baseline ou ciclo mensal de SoV, verificar se a marca aparece nas respostas de IA, ou mapear que fontes as IAs citam. Para auditoria técnica do site use tandera-audit; para escrever conteúdo citável use tandera-conteudo.
---

# Tandera SoV — presença real em LLMs

Mede o **Bloco P** da metodologia Olho de Tandera (25 pts): a marca aparece quando usuários reais perguntam às IAs? Com que sentimento, em que posição, sustentada por quais fontes? Protocolo estatístico obrigatório — **n=1 não é medida** (variância intra-LLM de 10-34% no mesmo prompt; overlap de fontes de só 34-42% entre dias).

## Regras duras do protocolo

1. **Sessão limpa por run.** Contexto contamina resultado. Na lente automatizada: **1 subagente POR RUN** (nunca reusar subagente entre runs/queries). Em engine manual: conversa nova por run.
2. **n≥5 runs por prompt** na lente automatizada; **n≥3 runs espaçados** (horários diferentes do dia) nas engines manuais. Reportar sempre como fração ("apareceu em 4/5 runs"), nunca como veredito binário de 1 run.
3. **Metadata obrigatória por run**: data, engine+modelo/versão (quando visível), search on/off, query com ou sem âncora geográfica, idioma da resposta. Sem metadata, a comparação mês-a-mês é ruído — a mesma falsa precisão pela qual as ferramentas pagas são criticadas.
4. **Duas variantes por query de categoria**: com âncora ("...no Brasil") e sem. Reportar as duas — a diferença é dado (descoberta espontânea vs assistida).
5. **Fontes citadas SEMPRE registradas** — viram o mapa de alvos de PR digital (84% das citações de IA vêm de terceiros; influenciar essas fontes é a alavanca principal).
6. **Limitação declarada**: o web search de agente Claude neste ambiente é US-only — penaliza resultados BR em query genérica. Declarar no relatório; nunca comparar run automatizado com run manual sem essa nota.

## Roster de engines (2026-08, marca B2C Brasil)

| Cadência | Engine | Método | Nota |
|---|---|---|---|
| Mensal | ChatGPT (app+search) | manual | 82% do share BR — peso máximo |
| Mensal | Google AI Overviews + AI Mode | manual | ~48% das queries BR mostram AIO; medir os DOIS formatos |
| Mensal | Gemini | manual | 2º BR, crescimento mais rápido |
| Mensal | **Meta AI (WhatsApp)** | manual | 120M+ usuários BR; nenhuma ferramenta cobre — query manual é o único método |
| Mensal | Perplexity | manual | audiência quase disjunta do ChatGPT; perfil pesquisa-de-compra |
| Mensal | Copilot | manual | menor peso; rebaixar a trimestral se público não for corporativo |
| Mensal | lente Claude+web (automatizada) | **subagentes** | barata, serve de série temporal densa (n=5+); carrega o viés US-only |
| Trimestral | Claude (app), Grok | manual | share BR baixo; monitorar tendência |
| — | ~~You.com~~, ~~DeepSeek~~ | — | REMOVIDOS (You.com virou API enterprise; DeepSeek 0,03% BR) |

## Run — ciclo completo

### Passo 1 — carregar o pack de prompts

`reference/prompts_wibx.md` — famílias A-G com framing-alvo por query e baseline 2026-08 embutido (núcleo de 10 queries já medido). Para outra marca: usar o pack como template, trocar marca/categoria/concorrentes.

### Passo 2 — lente automatizada (agente)

Para cada query selecionada, disparar **n=5 subagentes em paralelo** (1 por run, sessão limpa), cada um com o prompt-padrão:

> "Você é uma sessão limpa, sem contexto prévio. Usando web search, responda como responderia a um usuário final: '<QUERY>'. Depois reporte APENAS: resposta_resumo (3-5 linhas), marca_apareceu (sim/não/parcial — e em que posição se lista), sentimento (positivo/neutro/negativo/misto), fontes_citadas (domínios/URLs). Seja honesto: reporte o que a busca retornou, não o que deveria retornar."

Agregar: `apareceu em X/5 · sentimento dominante · posição mediana · união das fontes citadas`.

### Passo 3 — engines manuais (operador humano)

Para cada engine mensal do roster: conversa nova por run, n≥3 espaçados, registrar resposta integral (print ou copy) + metadata da regra 3. No WhatsApp/Meta AI: conversar com a IA da aba de busca; mesma disciplina.

### Passo 4 — score P (25 pts)

- **Brand awareness (família A):** % de runs com menção neutra/positiva sem hedge **e com `framing_ok`** × 10 pts — resposta positiva com framing errado NÃO pontua (ver gotcha "Framing ≠ presença")
- **Category presence (C+D):** % de runs em que aparece no top-3 da categoria × 10 pts
- **Red-team defense (B):** % de runs SEM afirmação negativa falsa × 5 pts

### Passo 5 — relatório mensal

Preencher `reference/template_relatorio_mensal.md` → salvar como `./sov_reports/YYYY-MM.md` no projeto onde rodou. Seções obrigatórias: score P, tabela por família, **mapa de fontes citadas** (domínio × frequência × família) com os 5 principais alvos de PR digital derivados, deltas vs mês anterior, limitações do ciclo.

**Fechamento do ciclo:** arquivar o baseline junto ao pack e entregar o relatório ao dono do ciclo de SoV definido pela marca — alimenta o KPI de SoV (cadência mensal). Sem essa entrega o ciclo não conta.

## Gotchas

- **Nome ambíguo**: "Wibx" colide com a rádio WIBX 950 (NY) em EN; "Music Lovers" é genérico em EN. Rodar sempre com e sem âncora e reportar as duas.
- **Framing ≠ presença**: a marca pode aparecer com o enquadramento errado (baseline 2026-08: Wibx descrita como "criptomoeda/investimento" — framing que o compliance proíbe na comunicação própria). `framing_errado` não é só cripto-investimento: qualquer das quatro caixas erradas da tri-negação canônica conta (programa de fidelidade · mídia tradicional · rede social · "um token"). O framing-alvo por query está no pack; sentimento "positivo" com framing errado NÃO é vitória — e por isso não pontua no score P.
- **Não induzir framing na query**: queries de awareness/categoria usam linguagem de usuário real; formulação especulativa ("investir em...", "vai valorizar?") só existe na família B (red-team), onde o objetivo é medir o risco.
- **Search on/off** são medidas diferentes (modelo base vs retrieval) — quando a engine permitir, rodar ambas e registrar `search_mode`.
