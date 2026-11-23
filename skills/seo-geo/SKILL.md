---
name: seo-geo
description: >-
  Executor de SEO técnico por página: varre TODAS as páginas do build ou do sitemap e
  CORRIGE no repo, numa branch, respeitando os gates. Cobre title/description, canonical,
  hreflang, H1 único e hierarquia de headings, Open Graph/Twitter, validade e tipos de
  JSON-LD (Organization, WebSite, FAQPage, Breadcrumb), alt de imagem, página que só
  renderiza com JS, robots.txt e sitemap. Agnóstica de stack (Next, Vite, Astro, Nuxt,
  WordPress, Webflow). É a base de SEO de que GEO depende. Use quando o usuário pedir para
  otimizar, auditar ou corrigir SEO de um site, ranquear no Google, ajustar meta tags,
  schema/structured data, hreflang, canonical, sitemap, ou aplicar no código as correções
  de um relatório tandera-audit. Dispara em "otimiza o site pra busca", "audita o SEO",
  "corrige as meta tags", "coloca schema", "por que não aparecemos no Google", "/seo-geo".
  Nota GEO/AEO do site → tandera-audit; medir presença em IAs → tandera-sov; escrever
  conteúdo citável → tandera-conteudo.
---

# SEO + GEO (executor)

Esta skill **conserta**. Ela cobre a camada de SEO técnico, página por página, de que
qualquer visibilidade em IA depende: 76% das páginas citadas em AI Overviews estão no
top-10 orgânico, e motores generativos recuperam do índice de busca antes de responder.

## Fronteira com a família tandera

| Pergunta | Skill |
|---|---|
| "Qual a nota GEO/AEO do site?" / política de bots de IA | **tandera-audit** |
| "A marca aparece no ChatGPT/Perplexity?" | **tandera-sov** |
| "Escreve a página 'o que é' / FAQ citável" | **tandera-conteudo** (gate de compliance WBX) |
| "Corrige o SEO de todas as páginas, no código" | **seo-geo** (esta) |

Fonte da verdade compartilhada, **não redefina aqui**: política de `robots.txt` (search
e user-fetch sempre liberados, treino é decisão editorial) em
`tandera-audit/reference/robots_txt_para_geo.md`; `llms.txt` como ruído fora de site de
documentação em `tandera-audit/reference/gotchas_2026.md` §6. Se o usuário trouxer um
relatório tandera-audit, use os itens técnicos dele como backlog desta skill.

## Arquivos de apoio

- `scripts/audit.py`: auditoria determinística por página, só stdlib. Rode sempre.
- `references/checklist.md`: cada item com por quê, como verificar e correção. Leia antes
  do relatório.
- `references/stacks.md`: onde aplicar cada correção em cada stack. Leia antes de editar.

## Fluxo

### 1. Reconhecer o terreno

- Leia `CLAUDE.md` / `AGENTS.md` / `CONTRIBUTING.md` e os scripts do `package.json`.
  Repos Wibx têm regra de branch/PR e gates de conteúdo, e a correção precisa passar por
  eles.
- Detecte a stack (`stacks.md`) e **onde a meta já é definida** (arquivo de conteúdo,
  layout, plugin). Corrija na fonte, nunca no HTML gerado.
- Descubra o domínio canônico de produção e os idiomas.

### 2. Auditar

```bash
# com repo: build primeiro, depois a pasta de saída
python3 <skill>/scripts/audit.py dist
# site ao vivo, ou sem repo (WordPress, Webflow)
python3 <skill>/scripts/audit.py https://dominio.com --max 30
```

Exit 1 = há ERROR. O script cobre o mecânico, sem você gastar tokens lendo dezenas de
HTMLs. Depois dele, leia 3–5 páginas-chave (home, produto principal, sobre) para o que
exige julgamento:
- O `<title>` e o `<h1>` carregam o termo que o público busca, ou só slogan?
- A description responde "o que é, para quem, por quê"?
- A `Organization` tem `sameAs` completo e dados factuais?
- O FAQ marcado em `FAQPage` está visível na página com o mesmo texto?

Se houver URL de produção, audite também. Prod e build divergem (CDN, redirects). Se
`curl` devolver 403, o site bloqueia clientes não-browser: registre e consulte
tandera-audit gotchas §1 em vez de inventar resultado.

### 3. Relatório

Entregue antes de editar:

```markdown
# SEO — <site> — <data>

**Veredito:** 1–2 frases: o maior bloqueio e o maior ganho.

## P0 — bloqueia indexação
- [ ] <achado> · <onde> · <correção>

## P1 — perde ranking ou clique
## P2 — polimento

## Fora do código (dono decide)
Copy nova, perfis externos, painel CMS/CDN, Search Console, bots de treino.
```

Agrupe repetições ("title >60 chars em 14 páginas: lista"). Dentro de cada faixa,
ordene por impacto ÷ esforço.

### 4. Corrigir

Escopo padrão: P0 + P1 técnicos.
- Siga a regra de branch/PR do repo. Nunca commite direto na main.
- Um commit por preocupação (meta, JSON-LD, i18n, robots/sitemap), para facilitar a
  revisão.
- Gere sitemap e hreflang **da mesma fonte das rotas**, nunca de uma lista paralela.
- JSON-LD: uma `Organization` com `@id` estável (`https://dominio/#organization`),
  referenciada pelas demais. Só marque o que está visível.
- Site bilíngue: toda mudança vale nos dois idiomas, traduzida de verdade.
- Não troque a ferramenta de meta/prerender que o repo já usa. SPA sem prerender é
  mudança de arquitetura: proponha antes de fazer.
- Encurtar title/description muda texto de marca. Proponha o novo texto e peça
  aprovação. Para conteúdo novo (FAQ, página "o que é"), passe a bola à tandera-conteudo,
  que tem o gate de compliance WBX.

### 5. Verificar

- Gates do repo verdes (`npm run build` ou equivalente).
- `audit.py` de novo: os ERRORs tratados sumiram e nenhum novo apareceu. Coloque o
  antes/depois (contagem por nível) no PR.
- JSON-LD novo validado em <https://validator.schema.org>.
- Liste o que fica com o dono: submeter o sitemap no Search Console e no Bing Webmaster
  Tools (o Bing alimenta ChatGPT e Copilot), toggle de bots de IA na CDN, perfis
  `sameAs`. Sugira rodar tandera-audit e tandera-sov depois para medir o efeito.

## Armadilhas

- **SPA sem prerender**: o P0 mais comum e mais caro, porque tudo fica invisível para
  crawlers de IA, que não executam JS. Cheque primeiro.
- **Canonical do en apontando para o pt** faz a versão en sumir do índice.
- **`FAQPage` com texto ausente da página** viola as diretrizes do Google.
- **`noindex` em paginação ou draft** pode ser intencional. Pergunte antes de remover.
- **Title >60 chars** é WARN. Encurte quando houver termo útil sendo cortado, não por
  causa do número.
