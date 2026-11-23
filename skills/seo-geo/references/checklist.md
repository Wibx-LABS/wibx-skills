# Checklist SEO técnico + GEO

Cada item: **o que** · **por que** · **como verificar** · **correção típica**.
Prioridade: P0 bloqueia indexação/citação · P1 perde ranking/clique · P2 polimento.

## Índice
1. Indexabilidade (P0)
2. Meta por página (P0/P1)
3. Estrutura do conteúdo (P1)
4. Internacionalização (P1)
5. Structured data / JSON-LD (P1)
6. Social (P2)
7. GEO → skill tandera-audit
8. Performance (P1)

---

## 1. Indexabilidade (P0)

| Item | Por que | Verificar | Correção |
|---|---|---|---|
| Conteúdo no HTML servido | Googlebot renderiza JS com atraso; crawlers de IA (OAI-SearchBot, Claude-SearchBot, PerplexityBot) **não executam JS**. SPA sem prerender = página vazia para IA. | `curl -s URL \| sed 's/<[^>]*>//g' \| wc -w`; o `audit.py` acusa <80 palavras | Prerender/SSG/SSR (ver `stacks.md`) |
| `robots.txt` não bloqueia bots de search nem de fetch do usuário | Bloqueio = sumiço do índice e das citações. Bots de treino: decisão editorial | `audit.py` | Modelo canônico em tandera-audit `reference/robots_txt_para_geo.md` |
| Linha `Sitemap:` no robots | Descoberta | idem | `Sitemap: https://dominio/sitemap.xml` |
| `sitemap.xml` só com URLs canônicas, 200, indexáveis | Sitemap com 404/redirect/noindex queima crawl budget e confiança | Cruzar `<loc>` com status HTTP | Gerar a partir da mesma fonte que define as rotas |
| `noindex` só onde é intencional | Um `noindex` esquecido em produção derruba a página | `audit.py` lista todos | Confirmar com o dono; drafts/paginação podem ser intencionais |
| Status HTTP corretos | Soft-404 (200 com "não encontrado") confunde o índice | `curl -I` numa rota inexistente | Servir 404 real |

## 2. Meta por página (P0/P1)

| Item | Regra | Nota |
|---|---|---|
| `<html lang>` | `pt-BR`, `en`… | P0 para i18n e leitores de tela |
| `<title>` | único, ≤60 chars, termo principal no começo, marca no fim (`Termo — Wibx`) | Acima de 60 o Google trunca/reescreve |
| `meta description` | única, 50–160 chars, responde "o que é + para quem + por que" | Não é fator de ranking; é fator de **clique** e é o resumo que IAs costumam reaproveitar |
| `canonical` | absoluto, auto-referente, sem query/trailing inconsistente | Evita duplicata pt/en, `?utm`, `/` vs sem `/` |

## 3. Estrutura do conteúdo (P1)

- **Exatamente um `<h1>`** por página, com o termo principal.
- Headings sem salto (h2→h4 quebra a outline usada por leitores e por chunking de LLMs).
- `alt` descritivo em imagens de conteúdo; `alt=""` em decorativas.
- Links internos com texto descritivo (nada de "clique aqui").
- URLs legíveis, minúsculas, com hífen, estáveis. Mudou a URL → redirect 301.

## 4. Internacionalização (P1)

- `<link rel="alternate" hreflang="pt-BR" href=…>` + `hreflang="en"` + **`x-default`**, em **todas** as versões, recíprocos (pt aponta en e en aponta pt).
- Cada idioma com o próprio canonical (o en **não** canoniza para o pt).
- `og:locale` / `og:locale:alternate`.
- Conteúdo realmente traduzido — página en com texto pt é sinal de baixa qualidade.

## 5. Structured data / JSON-LD (P1)

Valide sempre em <https://validator.schema.org> e no Rich Results Test do Google.

| Tipo | Onde | Campos que importam |
|---|---|---|
| `Organization` | home (ou todas, via `@id`) | `name`, `url`, `logo`, `sameAs` (LinkedIn, Instagram, GitHub, Wikipedia/Wikidata se houver), `contactPoint`, `foundingDate`, `address` |
| `WebSite` | home | `name`, `url`, `inLanguage`, `publisher → @id da Organization` |
| `BreadcrumbList` | páginas internas | espelha a hierarquia real da URL |
| `FAQPage` | páginas com FAQ visível | as perguntas **precisam estar visíveis** na página; texto idêntico |
| `Product` / `SoftwareApplication` / `Service` | páginas de produto | `name`, `description`, `provider → Organization`, `offers` só se houver preço real |
| `Article` / `BlogPosting` | posts | `headline`, `datePublished`, `dateModified`, `author` (Person com `url`), `image` |

Regras:
- Um `@id` estável por entidade (`https://dominio/#organization`) e referencie por `@id` em vez de duplicar.
- Nunca marque o que não está visível na página. Isso viola as diretrizes do Google e gera ação manual.
- `FAQPage` não gera mais rich result para a maioria dos sites, mas **continua valendo para GEO**: é o formato pergunta→resposta que LLMs extraem.

## 6. Social (P2)

`og:title`, `og:description`, `og:image` (1200×630, <300 KB, URL absoluta), `og:url`, `og:type`, `og:site_name`, `twitter:card=summary_large_image`. Prévia de link no WhatsApp/LinkedIn/Slack sai daqui.

## 7. GEO (P0/P1)

Não duplicado aqui. Nota de prontidão GEO, política de bots por categoria e gotchas:
skill **tandera-audit** (`reference/robots_txt_para_geo.md`, `reference/gotchas_2026.md`).
O que esta checklist já cobre e é pré-requisito de GEO: conteúdo no HTML sem JS (§1),
`Organization` com `sameAs` (§5) e FAQ visível + `FAQPage` (§5). Lembrete: 76% das páginas
citadas em AI Overviews estão no top-10 orgânico, então SEO clássico é o caminho.

## 8. Performance (P1)

Core Web Vitals: LCP < 2,5 s · INP < 200 ms · CLS < 0,1.
Medir: `npx lighthouse URL --only-categories=performance,seo --quiet` ou PageSpeed Insights.
Correções usuais: imagem do hero em WebP/AVIF com `width`/`height` e `fetchpriority="high"`; lazy-load abaixo da dobra; fontes com `font-display: swap` + preload; evitar layout shift de banners de cookie.
