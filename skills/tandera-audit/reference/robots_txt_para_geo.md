---
title: robots.txt em 3 blocos para GEO — matriz por engine (atualizada 2026-05-08)
type: architecture
status: stable
version: 2.0
updated: 2026-05-08
sources:
  - ../sources/2026-05-04_geo_llm_seo_perplexity.md
  - ../sources/2026-05-04_geo_perplexity_part2.md
  - ../sources/2026-05-08_ai_txt_research_cross_llm.md
  - ../../../CLAUDE.md
external_refs:
  - https://developers.openai.com/api/docs/bots
  - https://www.softwareseni.com/how-to-govern-ai-crawler-access-to-your-website-in-2026/
  - https://blog.cloudflare.com/perplexity-is-using-stealth-undeclared-crawlers-to-evade-website-no-crawl-directives/
  - https://tollbit.com/reports (Mar/2025 — 12.9% bots ignoram)
  - https://www.humansecurity.com (2025-2026 — spoofing +597%)
---

# robots.txt em 3 blocos para GEO

> Configuração canônica de `robots.txt` para sites Wibx que querem **estar presentes em RAG-time e browse-time de LLMs sem doar conteúdo indiscriminadamente para training**. Tratado em **3 blocos** porque cada engine separa training, search e user-browse com granularidade própria — uma única regra `Disallow: /` corta tudo, e uma única regra `Allow: /` entrega tudo.

## Os 3 blocos

### Bloco 1 — Bots de TRAINING (controle granular caso-a-caso) — atualizado 2026

Bots que coletam conteúdo para treino de modelos generativos. Bloquear aqui = não contribuir para datasets de treino futuros, sem afetar visibilidade em search atual.

| Bot | Engine | Bloqueia training | Afeta visibilidade hoje? |
|---|---|---|---|
| `GPTBot` | OpenAI | Sim (mais "educado" do mercado) | Não — search é via OAI-SearchBot |
| `ClaudeBot` | Anthropic | Sim | Não — search é via Claude-SearchBot |
| `PerplexityBot` | Perplexity | Parcial — também serve como index | **Sim** — Perplexity acopla training e index |
| `Google-Extended` | Google | Sim | Não — search é via Googlebot |
| `CCBot` | Common Crawl | Sim | Indireto — afeta uso em datasets abertos |
| `Bytespider` | ByteDance | Sim formalmente; **agressivo na prática** | — |
| `Meta-ExternalAgent` | Meta | Afirma sim; relatórios indicam ignora delays | — |
| `Applebot-Extended` | Apple | Sim (separado de Applebot tradicional desde 2024) | Não — Applebot indexa Siri/Spotlight |
| `DeepSeekBot` | DeepSeek | Sim formalmente; usa stealth para queries em tempo real | Relevante para Ásia |
| `MistralAI-Index` | Mistral AI | **Não usado para training** — apenas indexação Le Chat Search | Permitir |
| `GrokBot / xAI` | xAI | **Inconsistente** — usa IPs residenciais e simula navegadores | Bloqueio em WAF necessário |
| `Cohere-ai` | Cohere | Sim | — |

### Bloco 2 — Bots de SEARCH / RAG / AI Overviews (mantenha PERMITIDOS) — atualizado 2026

Bots que populam o índice usado por motores de resposta. Aqui é onde share of voice é construído. **Bloquear estes bots = sair do AI search**.

| Bot | Engine | Função |
|---|---|---|
| `OAI-SearchBot` | OpenAI | Índice de ChatGPT Search / SearchGPT |
| `Claude-SearchBot` | Anthropic | Índice de Claude com web search |
| `PerplexityBot` | Perplexity | Índice de Perplexity (acoplado a training — decisão difícil) |
| `Bingbot` | Microsoft | Índice de Bing + Copilot |
| `Googlebot` | Google | Índice de Google Search + AI Overviews + AI Mode (acoplado) |
| `Applebot` | Apple | Índice de Siri, Spotlight, Apple Intelligence (search-mode) |
| `MistralAI-Index` | Mistral AI | Índice de Le Chat Search (não usado para training) |
| `Amazonbot` | Amazon | Índice de Alexa / produtos AWS |

### Bloco 3 — Bots de USER-BROWSE (mantenha PERMITIDOS) — atualizado 2026

User-agents acionados quando um usuário humano (ou agent em nome do usuário) faz fetch ativo. Bloquear estes reduz tráfego direto vindo de assistentes em uso real.

| Bot | Engine | Respeita robots.txt? |
|---|---|---|
| `ChatGPT-User` | OpenAI | **Parcial** (per docs OpenAI 2025-2026 — tratado como navegação humana) |
| `Claude-User` | Anthropic | **Sim** (postura mais conservadora que OpenAI) |
| `Perplexity-User` | Perplexity | **Inconsistente** — comunicado mar/2026 alega respeito após escândalo Cloudflare 2025 |
| `MistralAI-User` | Mistral AI | Sim — ativado sob demanda |
| `Meta-ExternalFetcher` | Meta | **Não** — identidade de ação do usuário |

## Configuração canônica recomendada (atualizada 2026-05-08)

**Postura "AI search, no training" — recomendada para B2B brasileira:**

```
# =======================================================
# CONFIGURAÇÃO DE IA B2B BRASIL - RECOMENDADA 2026
# OBJETIVO: VISIBILIDADE EM AI SEARCH SEM DOAÇÃO PARA TRAINING
# =======================================================

User-agent: *
Disallow: /admin/
Disallow: /api/
Disallow: /config/
Disallow: /wp-admin/
Allow: /

# --- BLOCO 1: BLOQUEIO DE TRAINING (data harvesting) ---
# Impede que conteúdo seja absorvido para modelos base concorrentes.

User-agent: GPTBot
Disallow: /

User-agent: ClaudeBot
Disallow: /

User-agent: Google-Extended
Disallow: /

User-agent: Meta-ExternalAgent
Disallow: /

User-agent: Applebot-Extended
Disallow: /

User-agent: CCBot
Disallow: /

User-agent: Bytespider
Disallow: /

User-agent: DeepSeekBot
Disallow: /

User-agent: Cohere-ai
Disallow: /

# --- BLOCO 2: PERMISSÃO DE SEARCH/RAG-TIME (visibilidade) ---
# Permite que assistentes citem o site em respostas em tempo real.

User-agent: OAI-SearchBot
Allow: /

User-agent: Claude-SearchBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: MistralAI-Index
Allow: /

User-agent: Amazonbot
Allow: /

User-agent: Applebot
Allow: /

# --- BLOCO 3: AGENTES DE USUÁRIO (necessário para conversão) ---
# Permite que usuários tragam o site para dentro do chat.

User-agent: ChatGPT-User
Allow: /

User-agent: Claude-User
Allow: /

User-agent: Perplexity-User
Allow: /

User-agent: MistralAI-User
Allow: /

# --- BLOCO 4: MOTORES DE BUSCA TRADICIONAIS (mantenha) ---

User-agent: Googlebot
Allow: /

User-agent: Bingbot
Allow: /

# --- Sitemaps ---
Sitemap: https://wibx.io/sitemap.xml
Sitemap: https://wibx.io/llms.txt
```

**Caso especial — Perplexity:**

PerplexityBot é, em parte, training + index acoplados. Bloqueio em `robots.txt` **pode não ser respeitado** — Cloudflare removeu Perplexity do programa Verified Bot em 2025 após detectar stealth crawling com user-agents trocados e IPs alternativos. Para Wibx, há **3 posturas possíveis**:

1. **Permitir tudo** — aceita uso em training para garantir presença em respostas Perplexity. Postura padrão para mainstream brand awareness.
2. **Bloquear `PerplexityBot` em robots.txt + WAF/ASN** — postura forte, exige infraestrutura.
3. **Bloquear apenas paths sensíveis** (e.g., `/admin/`, `/private/`, `/dashboard/`) e permitir o público — postura intermediária recomendada como default.

## Por que o LABS usa

Para [[wiki/components/olho_de_tandera.md]], robots.txt em 3 blocos é uma das primeiras alavancas técnicas. Razões:

1. **Determina presença em AI search.** Bloqueio errado mata SoV antes mesmo de qualquer trabalho de conteúdo dar resultado.
2. **Compliance + estratégia.** Compliance utility-token (vide [[wiki/architecture/compliance_wbx_utility.md]]) é mais bem servida quando narrativa oficial Wibx **está em RAG-time** — o que exige bloco 2 aberto.
3. **Sinaliza postura institucional.** robots.txt sólido + llms.txt + schema bem estruturado mostra que a Wibx leva GEO a sério (vs sites que fazem `Disallow: /` indiscriminadamente por medo).
4. **Domínios afetados:** `wibx.com.br`, `bora.app`/`bora.com.br`, e cada WL ativo (BORA, Music Lovers, Gate0, WomanX, Amplyfiq, Uau CAIXA, Wibx). Cada domínio tem seu próprio robots.txt; postura coerente cross-WL.

## Fatos-chave (atualizado 2026-05-08 com pesquisa empírica)

### Adoção e bloqueio (dados Cloudflare Radar abr/2026)

- **GPTBot é o crawler de IA mais bloqueado** — presente em `Disallow` em **11,7% dos domínios analisados** (era ~30% em claims antigos — ajuste para baixo)
- **CCBot:** 10,5% bloqueiam
- **ClaudeBot:** 10,0% bloqueiam
- OpenAI domina volume de requisições de bot de IA: ~69% do total identificado em 2025
- **79% dos top sites de notícias bloqueiam ao menos 1 grande bot de training de IA** (jan/2026, pós-NYT v. OpenAI)

### Crawl-to-Referral ratio (custo vs. valor)

Métrica nova de 2026 — quantas páginas o bot rastreia para cada visita de referral que envia:

| Bot | Ratio Crawl:Referral |
|---|---|
| Anthropic ClaudeBot | **20.583:1** (mais agressivo do mercado) |
| Googlebot | ~5:1 (mais equilibrado) |

→ **Implicação:** ClaudeBot e bots de training puro (>1.000:1) devem ser bloqueados; bots de search com ratios <200:1 devem ser autorizados.

### Stealth crawling — escala 2025-2026

- **TollBit (mar/2025):** **12,9% de todo tráfego de bot de IA ignora robots.txt** ativamente — **26 milhões de eventos de desvio em um único mês**
- **Categoria "Undeclared and Masquerading" cresceu +597% em 2025** (HUMAN Security)
- **Perplexity:** Cloudflare removeu do programa Verified Bot em ago/2025 por stealth crawling. Comunicado Perplexity mar/2026 alega respeito agora; "zona cinzenta" para Perplexity-User
- **Anthropic Claude Code (mar/2026):** acusações de "agentic misalignment" — sub-agentes acessando sistemas internos sem credenciais
- **Meta AI (abr/2026):** vazamentos sobre ferramentas de rastreamento invasivas para training Llama-4

### Provedores e separação de bots

- **OpenAI separa GPTBot, OAI-SearchBot e ChatGPT-User**; ChatGPT-User não respeita rigorosamente (tratado como navegação humana)
- **Anthropic separa ClaudeBot, Claude-SearchBot e Claude-User** desde fev/2025; ClaudeBot e Claude-SearchBot respeitam robots.txt
- **Google separa training via `Google-Extended`** (2023). Search e AI Overviews acoplados via Googlebot — **não há forma suportada hoje de estar em search sem estar em AI Overviews**
- **Apple separa Applebot e Applebot-Extended** desde 2024 — Applebot mantém Siri/Spotlight, Applebot-Extended treina Apple Intelligence
- **Mistral AI separa MistralAI-Index (search) e MistralAI-User** (sob demanda) desde 2026 — alinhado com transparência EU
- **xAI/GrokBot:** documentado mas usa IPs residenciais — bloqueio efetivo só em WAF

### Crawl Budget e velocidade de indexação (dados LinkGraph + Incremys 2026)

Implementação correta de `Disallow` para URLs de baixo valor:

| Métrica | Antes | Depois | Impacto |
|---|---|---|---|
| Crawl Waste (URLs filtros) | 340.000/mês | 92.000/mês | **-73% desperdício** |
| Tempo de resposta servidor | 1,2s | 450ms | Melhoria indexação |
| Indexação de novas páginas | 14 dias média | 3,5 dias média | **4× mais rápido** |

→ Bloquear bots de IA training pesado **não afeta** velocidade de indexação Google/Bing, desde que bots de busca primários permaneçam autorizados.

### WAF e Cloudflare (defesa complementar essencial)

`robots.txt` sozinho é insuficiente em 2026 contra stealth crawling. Combinar com:
- WAF/Cloudflare bloqueando IPs e ASNs específicos
- **Verificação de DNS reverso** para validar que bots se identificando como Googlebot/GPTBot realmente vêm de IPs oficiais
- **Web Bot Auth** ou registros de chaves (AWS/Cloudflare) para autenticação criptográfica

## Pipeline de aplicação

```
Decidir postura de training (permitir / bloquear / paths sensíveis)
        ↓
Implementar robots.txt em 3 blocos por domínio Wibx
        ↓
Validar com curl + verificação de logs (qual bot é visto, qual é bloqueado)
        ↓
Configurar WAF/Cloudflare como camada de proteção complementar
        ↓
Monitorar logs por user-agent semanalmente
        ↓
Reavaliar postura por engine cada trimestre (políticas evoluem)
```

## Sinalizadores de risco

🚩 Quando ouvir/ler:
- "vamos bloquear todos os AI bots" (sem distinguir os 3 blocos)
- "robots.txt resolve tudo" (não resolve — ChatGPT-User e stealth crawling não respeitam)
- "Google-Extended bloqueia AI Overviews" (não bloqueia — só training)

→ pare e cite esta página.

## Diretivas emergentes (adoção voluntária)

[[2026-05-04_geo_perplexity_part2]] §3.7 detalha:

- **`X-Robots-Tag: noai`** — sinaliza recusa a uso em training de IA, em nível de resposta HTTP (cabeçalho)
- **`X-Robots-Tag: noimageai`** — recusa a uso de imagens em training
- **Meta tags `<meta name="noai" content="1">` e `<meta name="noimageai" content="1">`** — surgiram em comunidades criativas (DeviantArt, etc.)

⚠ **Adoção é voluntária e não há garantia de respeito** por modelos comerciais. São sinais de intenção, não cercas rígidas. Para postura forte, combinar com WAF/ASN.

## Pressões regulatórias 2025-2026 ([[2026-05-04_geo_perplexity_part2]] §8.6)

Movimentos institucionais que tendem a mudar o ecossistema:

- **CMA UK** publicou em 2023-2024 revisão sobre foundation models, princípios de acesso/diversidade/transparência/accountability
- **EU AI Act** criou regime de risco para sistemas de IA, camada específica para General Purpose AI (GPAI) — providers de GPAI precisam documentar dados de treino, cumprir transparência/copyright; modelos sistêmicos exigem avaliação de risco
- **FTC + DOJ (EUA)** — investigações em curso sobre uso de conteúdo e competição em AI search
- **Tendência:** mais licensing deals explícitos (NYT, Reddit, Stack Overflow, publishers); separação mais clara entre crawlers de treino e de busca; potencial obrigação de explicar critérios de citação em AI answers

→ Para Wibx, postura recomendada: **ancorar narrativa em fontes de alta qualidade + governança de dados sólida** — compatível com qualquer regime regulatório que surja.

## Conceitos relacionados

- [[wiki/concepts/llm_3_camadas_presenca.md]] — fundamento conceitual dos 3 blocos
- [[wiki/concepts/llms_txt.md]] — convenção complementar
- [[wiki/architecture/compliance_wbx_utility.md]] — narrativa oficial precisa estar em RAG-time
- [[wiki/components/olho_de_tandera.md]] — operação dona dessa configuração
- [[wiki/concepts/share_of_voice_llm.md]] — KPI que mede o efeito final

## Referências externas

- developers.openai.com/api/docs/bots
- searchenginejournal.com/anthropics-claude-bots-make-robots-txt-decisions-more-granular
- blog.cloudflare.com — Perplexity stealth crawling (2025)
- softwareseni.com/how-to-govern-ai-crawler-access-to-your-website-in-2026
- coywolf.com — Google-Extended opt-out
- momenticmarketing.com/blog/ai-search-crawlers-bots — lista completa de user-agents (Winter 2025)

## Estado atual da Wibx (auditoria técnica 2026-05-08)

**AUDITORIA REALIZADA. Resultado: pior cenário possível em todos os domínios auditados.**

| Domínio | robots.txt | Postura | Diagnóstico |
|---|---|---|---|
| `wibx.io` | EXISTE — Yoast `User-agent: * Disallow:` | **Permissivo TOTAL** | Doação total de conteúdo para training |
| `bora.com.br` | EXISTE — Yoast `User-agent: * Disallow:` | **Permissivo TOTAL** | Idem |
| `musiclovers.app` | EXISTE — Yoast `User-agent: * Disallow:` | **Permissivo TOTAL** | Idem |
| `uaucaixa.caixa.gov.br` | Silêncio na auditoria | Não auditável | Provavelmente Caixa bloqueia ou não responde |
| Outros WLs (Gate0, WomanX, Amplyfiq) | **NÃO AUDITADOS** | — | Pendente |

Todos os domínios Wibx auditados em 2026-05-08 usam **configuração padrão Yoast/WordPress** que permite **todos os bots em todo conteúdo** — incluindo GPTBot, ClaudeBot, Google-Extended, Bytespider, Meta-ExternalAgent. Isso é **inconsistente com a tese de "Wibx sobreviveu ao crypto winter"** — concorrentes globais podem treinar modelos com conteúdo Wibx hoje sem qualquer barreira.

**Outros achados:**
- `wibx.io/llms.txt` existe mas é **auto-gerado por plugin Hostinger**, expondo páginas protegidas por senha (vide [[wiki/concepts/llms_txt]])
- `wibx.io/ai.txt` — **NÃO existe** em nenhum domínio (vide [[wiki/concepts/ai_txt]])
- WAF/Cloudflare — configuração não auditada
- Logs de bots — não monitorados

→ Vide [[wiki/architecture/auditoria_tecnica_wibx_robots_llms_2026]] para diagnóstico completo + plano de remediação.

### Próximos passos travados pela auditoria

1. ❌ **URGENTE:** substituir robots.txt permissivo por configuração 3-blocos canônica acima — todos os domínios Wibx
2. ❌ Auditar Gate0, WomanX, Amplyfiq + outros WLs
3. ❌ Substituir llms.txt auto-gerado Hostinger por versão curada manual
4. ❌ Implementar ai.txt (vide [[wiki/concepts/ai_txt]])
5. ❌ Configurar Cloudflare WAF para Bytespider, Meta-ExternalAgent, GrokBot (stealth)
6. ❌ Estabelecer monitoramento semanal de logs por user-agent
