# Onde aplicar as correções em cada stack

Primeiro **detecte** a stack (arquivo → stack). Depois procure o mecanismo **que o repo já
usa** para meta/head antes de introduzir outro. Dois sistemas de meta concorrentes geram
tags duplicadas.

| Sinal no repo | Stack | Pasta de build p/ `audit.py` |
|---|---|---|
| `next.config.*`, `app/` ou `pages/` | Next.js | `out/` (export) ou auditar a URL do `next start` |
| `astro.config.*` | Astro | `dist/` |
| `vite.config.*` + React/Vue sem SSR | SPA Vite | `dist/` (só serve se houver prerender) |
| `nuxt.config.*` | Nuxt | `.output/public/` |
| `svelte.config.*` | SvelteKit | `build/` |
| `gatsby-config.*` | Gatsby | `public/` |
| `_config.yml` / `.eleventy.js` / `hugo.toml` | SSG clássico | `_site/` / `public/` |
| `wp-content/` ou só URL | WordPress | auditar URL |
| só URL (Webflow, Framer, Wix…) | No-code | auditar URL; correção vai no painel do CMS |

## Next.js (App Router)

- Meta: `export const metadata` / `generateMetadata()` em `layout.tsx`/`page.tsx`.
  `metadataBase` no layout raiz (sem ele, OG e canonical saem relativos).
- Canonical + hreflang: `alternates: { canonical: '/x', languages: { 'pt-BR': '/x', en: '/en/x', 'x-default': '/x' } }`.
- JSON-LD: `<script type="application/ld+json" dangerouslySetInnerHTML={{__html: JSON.stringify(data)}} />` dentro do componente da página.
- `app/robots.ts`, `app/sitemap.ts` (convenção de arquivo).
- Pages Router: `next/head`, `next-sitemap`.

## Vite + React/Vue (SPA)

- **Prerender é obrigatório** para GEO. Veja se o repo já tem (`scripts/prerender*`,
  `vite-plugin-ssr`/`vike`, `vite-ssg`, `react-snap`, Puppeteer). Se tiver, use. Se não
  tiver, proponha ao dono antes de adicionar: é mudança de arquitetura.
- Meta: o que o repo já usar (`react-helmet-async`, `@unhead/vue`, `useHead`, injeção no
  prerender). Sem nada, a injeção no script de prerender é o caminho de menos dependência.
- `robots.txt`: em `public/` (copiados para `dist/`), ou emitidos pelo
  prerender quando derivam das rotas.
- Rotas costumam viver num arquivo de config/conteúdo. Gere sitemap e hreflang **dessa
  fonte**.

## Astro

- Meta em layout `.astro` (`<head>` com props). Integrações `@astrojs/sitemap`.
- JSON-LD: `<script type="application/ld+json" set:html={JSON.stringify(data)} />`.
- `public/robots.txt`.

## Nuxt / SvelteKit / Gatsby / SSG

- Nuxt: `useSeoMeta`, `useHead`, módulo `@nuxtjs/seo` se já estiver instalado.
- SvelteKit: `<svelte:head>`, `export const prerender = true`.
- Gatsby: `Head` API, `gatsby-plugin-sitemap`.
- Hugo/Jekyll/Eleventy: partial do `<head>` no layout base; front matter por página.

## WordPress

- Plugin SEO existente (Yoast, Rank Math, AIOSEO) faz meta, canonical, sitemap e schema.
  **Não duplique** com código manual.
- `robots.txt` virtual: no painel do plugin. `llms.txt` auto-gerado por plugin pode listar
  página protegida por senha (gotchas_2026 §6). Confira ou desligue.
- Cache/CDN (WP Rocket, Cloudflare): confira se não bloqueia bots de IA.

## No-code (Webflow, Framer, Wix)

Não há repo para mudar. Entregue o relatório + um passo-a-passo de painel: onde fica o
SEO por página, o "custom code" do `<head>` para o JSON-LD, upload do `robots.txt` (Webflow:
Site settings → SEO). Hospedagens que não aceitam arquivo na raiz:
registre como limitação.

## Gates do repo

Antes de editar, leia `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md` e `package.json`
(scripts). Repos Wibx costumam ter gates de conteúdo (ex.: meta obrigatória por status,
paridade de idioma, checagem de âncoras). A correção precisa passar por eles, e meta que
vive em arquivo de conteúdo deve ser editada lá, não no template.
