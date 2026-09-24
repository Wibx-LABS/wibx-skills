---
name: wibx-presentations
description: Cria apresentações HTML premium da Wibx em arquivo único, no Manual da Marca (verde #22ff7b sobre #070707, Clash Display, logo oficial "wibx COMPANY"), com palco fixo 1920x1080, animação GSAP por slide, 61 modelos de diagrama e gráfico já recoloridos na marca, e QA automático (estático + navegador). Use SEMPRE que pedirem deck, slides, apresentação, pitch, keynote, palestra, retrospectiva, one-pager em slides ou storytelling visual da Wibx, inclusive a partir de markdown, de um texto solto ou para converter um PPT/PPTX para web. Também quando pedirem diagrama ou gráfico para um slide.
compatibility: python3 (stdlib; Pillow só para recorte de imagem com alfa). Navegador Chromium para o QA visual. CDN em runtime do deck (Fontshare, jsDelivr/GSAP). Depende da skill wibx-brand instalada ao lado.
---

# Wibx Presentations

Deck HTML de arquivo único, no nível de agência, dentro do Manual da Marca. Esta skill diz
**o que fazer em que ordem**; as regras detalhadas moram em `references/` e o código pronto
em `templates/` e `scripts/`. Caminhos abaixo são relativos à pasta desta skill.

| Arquivo | Para quê |
|---|---|
| `../wibx-brand/references/manual.md` | Lei da marca: cores, fonte, logo, proibições. Leia inteiro na Fase 0. |
| `references/design.md` | Design read, dials, tese visual, proibições, pre-flight. |
| `references/diagramas.md` | Catálogo dos 61 modelos: qual usar para quê, receita de animação. |
| `references/licoes.md` | Erros reais já corrigidos. Leia antes da Fase 4. |
| `templates/deck.src.html` | Esqueleto: tokens do manual, capa, abertura de seção, bento, diagrama, fechamento. |
| `templates/build.py` | Monta o arquivo único (CSS/JS do palco, logo, `parts.py`, numeração). |
| `templates/controller.js`, `templates/stage.css` | Palco 16:9 escalável, navegação, timeline GSAP, modo edição, print. Embutidos pelo build. |
| `templates/diagrams.py` | Geometria paramétrica (loop radial). |
| `scripts/brand_gallery.py` | Recolore a galeria inteira na marca, dentro do projeto. |
| `scripts/extract_svg.py` | Tira o SVG de um modelo com ids prefixados e marcação de animação. |
| `scripts/qa_static.py`, `scripts/qa_browser.js` | QA do HTML final. |
| `gallery/original/` | Galeria diagram-design (MIT, `gallery/LICENSE`). Fonte do recolor; não use direto no deck. |

Escopo de marca: deck usa o **Manual da Marca**, nunca o tema Admin Dashboard (`#00ff70`,
Red Hat Display), que é de UI de produto. Decisão de 2026-09-24.

## Fase 0: Briefing

1. Leia `../wibx-brand/references/manual.md` inteiro.
2. Descubra: objetivo, público (engenharia / misto / executivo), modo (palestra ao vivo ou leitura
   enviada), duração ou número de slides, conteúdo-fonte (markdown, texto, PPTX, dados).
   Pergunte só o que não dá para inferir, uma pergunta por vez.
3. Markdown com `---` entre slides é aceito como conteúdo; a skill escolhe o layout de cada slide.
   PPTX: extraia texto e números (skill `docling-parser` ou `anthropic-skills:pptx`), depois redesenhe; nunca copie o layout do PPT.
4. Declare em uma linha o design read e os dials (`references/design.md` §1).

## Fase 1: Roteiro e direção

1. Escreva o roteiro: um título-afirmação por slide (a frase que o slide prova), não um rótulo.
   Mostre ao usuário antes de gerar HTML se o deck tiver mais de 6 slides.
2. Para cada slide, escolha a estrutura: capa, abertura de seção, statement, bento de números,
   diagrama, comparação, fechamento. Varie (design.md §2).
3. Slide que explica sistema, processo, tempo, hierarquia, comparação ou números vira diagrama:
   escolha o modelo pela tabela "O slide precisa mostrar..." de `references/diagramas.md`.
   Diagrama só quando ensina mais que o parágrafo.

## Fase 2: Diagramas

1. `python3 scripts/brand_gallery.py <projeto>/diagramas`. Nunca gere dentro da pasta da skill.
2. Abra o exemplo `-dark` do modelo, extraia: `python3 scripts/extract_svg.py <projeto>/diagramas/example-<modelo>-dark.html <prefixo> --anim`.
3. Remova o `<rect>` de fundo de tela cheia, adicione `class="dg"`, troque pelos dados reais
   (nunca invente componente para encher layout). Grade de 4px.
4. Geometria calculada (loop, radial, interseção): gere com `templates/diagrams.py` em
   `<projeto>/parts.py`, nunca chute coordenadas.
5. Contrato: `<svg role="img" aria-labelledby="<p>-title <p>-desc">`, `<title>` primeiro filho,
   ids prefixados, 1 a 2 focais em verde, conectores ortogonais, legenda em faixa inferior.

## Fase 3: Animação

- Convenções do `controller.js`: `[data-r]` reveal de leitura; `[data-seq]` + `.draw` / `.pop` /
  `.fade` ordem do diagrama; `data-step` no `<section>` = ritmo; `[data-count]` contador (o texto
  no fonte já é o valor final); `data-packet` no conector = pacote percorrendo o caminho real.
- Receita por família em `references/diagramas.md` (R-FLUXO, R-SEQ, R-BARRA...).
- MOTION ≤ 4: remova a tag do GSAP; o deck fica estático com reveal só por CSS se quiser.
- Objeto animado e sua moldura/brilho no mesmo wrapper (lições C1). Toda animação precisa de motivo.

## Fase 4: Geração e QA (obrigatório, nesta ordem)

Projeto (fora da pasta da skill, p.ex. no diretório de trabalho do usuário):
```
<projeto>/deck.src.html   copiado de templates/deck.src.html e editado (Edit/Write)
<projeto>/parts.py        opcional: PARTS = {"NOME": "<svg ou base64>"} para %%NOME%%
<projeto>/assets/         imagens de origem
<projeto>/diagramas/      galeria na marca (Fase 2)
<projeto>/deck.html       saída de arquivo único: é o que se entrega
```

1. Leia `references/licoes.md`.
2. `python3 templates/build.py <projeto>` e `python3 scripts/qa_static.py <projeto>/deck.html` precisa dar `OK`.
3. Navegador no HTML **final** (sirva com `python3 -m http.server`), viewport 1920x1080, cole o
   conteúdo de `scripts/qa_browser.js` e rode `apthtmlQA.run()`, que precisa dar `[]`.
   Venn/zonas: `apthtmlQA.labelsInCircles(...)` com folga ≥ 16px.
   Sem Claude in Chrome: Chromium headless com `--dump-dom` num clone do deck que injeta o
   script e escreve o resultado num `<pre>`; screenshot com `--screenshot` (lições E6, E7).
4. Para cada slide animado: captura no meio (≈1,2 s) e no fim (≈4 s ou `--force-prefers-reduced-motion`).
   Confira pontas de seta, pacotes, alinhamento em card estreito, espaço morto.
5. Pre-flight de `references/design.md` §5. Console sem erro. Teste de celular (o palco só escala).

## Fase 5: Entrega

- Entregue o caminho do `deck.html`. Liste o que foi decidido e **pergunte** sobre divergência
  de conteúdo ou marca encontrada (nunca corrija fato em silêncio).
- PDF só se pedido: imprimir no Chrome, paisagem, sem margens (o `@media print` do palco já pagina 1 slide por folha).
- Nunca publique (Vercel, Artifact, link público) sem confirmação explícita naquele momento.
- Quando o usuário corrigir algo, registre em `references/licoes.md` (aconteceu, por quê, regra,
  como verificar) e, se couber, automatize em `qa_static.py` ou `qa_browser.js`.
