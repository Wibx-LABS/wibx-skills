# Manual: SEO + GEO Skill

---

#### 🇺🇸 English
**What it does:**
The executor for per-page technical SEO. It crawls **every** page of a build folder or sitemap and **fixes** what it finds in the repo, on a branch, through the repo's gates. This is the SEO base that GEO depends on: 76% of pages cited in AI Overviews rank top-10 organically. Stack-agnostic.

**Where it fits:** `tandera-audit` scores GEO/AEO readiness · `tandera-sov` measures real presence in LLMs · `tandera-conteudo` writes citable content · **`seo-geo` fixes the code**. Robots/llms.txt policy is defined by tandera-audit and not redefined here.

**Key Features:**
- **Deterministic Per-Page Audit:** `scripts/audit.py` (stdlib only), on a build folder or a live URL: title, description, canonical, hreflang/x-default, OG/Twitter, JSON-LD validity and types, single H1, heading jumps, img alt, JS-only pages, robots.txt (search/user-fetch bots blocked = ERROR, training bots = INFO), sitemap, site-wide Organization/WebSite. Exit 1 on ERROR, so it works as a gate.
- **Prioritized Report:** P0/P1/P2, plus an "owner decides" list.
- **Fix at the Source:** content files and layouts, never generated HTML. One commit per concern. New brand copy is proposed, not forced.
- **Per-Stack Guide:** Next.js, Vite SPA, Astro, Nuxt, SvelteKit, Gatsby, SSGs, WordPress, Webflow/Framer.

**Usage:**
"audit and fix this site's SEO", "apply the tandera-audit fixes", `/seo-geo`, or `python3 scripts/audit.py dist` / `audit.py https://site.com`.

---

#### 🇧🇷 Português
**O que faz:**
Executor de SEO técnico por página. Varre **todas** as páginas da pasta de build ou do sitemap e **corrige** o que encontra no repo, numa branch, passando pelos gates. É a base de SEO de que GEO depende: 76% das páginas citadas em AI Overviews estão no top-10 orgânico. Agnóstica de stack.

**Onde se encaixa:** `tandera-audit` dá a nota de prontidão GEO/AEO · `tandera-sov` mede a presença real em LLMs · `tandera-conteudo` escreve conteúdo citável · **`seo-geo` corrige o código**. A política de robots/llms.txt é definida pela tandera-audit e não é redefinida aqui.

**Principais Recursos:**
- **Auditoria Determinística por Página:** `scripts/audit.py` (só stdlib), na pasta de build ou numa URL ao vivo: title, description, canonical, hreflang/x-default, OG/Twitter, validade e tipos de JSON-LD, H1 único, saltos de heading, alt de imagem, página que só renderiza com JS, robots.txt (bot de search/user-fetch bloqueado = ERROR, bot de treino = INFO), sitemap, Organization/WebSite no site. Exit 1 com ERROR, então serve de gate.
- **Relatório Priorizado:** P0/P1/P2, mais uma lista "dono decide".
- **Corrige na Fonte:** arquivos de conteúdo e layouts, nunca o HTML gerado. Um commit por preocupação. Copy nova de marca é proposta, não imposta.
- **Guia por Stack:** Next.js, SPA Vite, Astro, Nuxt, SvelteKit, Gatsby, SSGs, WordPress, Webflow/Framer.

**Uso:**
"audita e corrige o SEO do site", "aplica as correções do tandera-audit", `/seo-geo`, ou `python3 scripts/audit.py dist` / `audit.py https://site.com`.
