---
name: wibx-presentations
description: APTHTML (Apresentação HTML) da Wibx. Orquestra o stack de apresentações HTML premium com animação. Use SEMPRE que o usuário pedir apresentação, deck, slides, pitch, keynote, palestra, retrospectiva ou storytelling visual em HTML (ou converter PPT/PPTX para web), especialmente com animações, diagramas ou identidade de marca. Lê frontend-slides, frontend-design, design-taste-frontend, high-end-visual-design, diagram-design e gsap-skills (cópias em vendor/) na ordem certa, com catálogo dos 61 diagramas, Manual da Marca Wibx e QA automático.
compatibility: python3 (stdlib; Pillow só para recorte de imagem com alfa). Navegador Chromium para o QA visual. CDN em runtime do deck (Fontshare, jsDelivr/GSAP). Depende da skill wibx-brand instalada ao lado.
---

# APTHTML: Apresentação HTML (stack orquestrado)

Base: pacote apthtml (colega, 2026-09-23), portado para este repo. Este skill define QUAIS skills
ler, em QUE ordem, quem manda em cada decisão, e traz as ferramentas e lições que já foram
validadas. As skills do stack estão copiadas em `vendor/` (origem e commit em `vendor/SOURCES.md`):
leia o `SKILL.md` de cada uma **inteiro** no momento indicado, como se tivesse carregado a skill.
Caminhos abaixo são relativos à pasta desta skill.

**Arquivos deste skill:**
| Caminho | Para quê |
|---|---|
| `references/licoes.md` | Erros reais já cometidos e corrigidos. **Leia antes da Fase 4.** |
| `references/diagramas.md` | Catálogo dos 61 modelos do diagram-design: quando usar, tipo, receita de animação |
| `vendor/diagram-design/assets/` | Galeria oficial (61 modelos × variantes) |
| `templates/` | `build.py`, `deck.src.html` (esqueleto na marca), `diagrams.py` (geometria paramétrica), `controller.js` (palco, navegação, GSAP, edição), `stage.css` |
| `scripts/qa_static.py` | QA do HTML final: travessões, placeholders, ids duplicados, paleta, a11y dos SVGs |
| `scripts/qa_browser.js` | QA no navegador: fora do palco, texto estourando, títulos longos, sobreposição, rótulos x círculos |
| `scripts/brand_gallery.py` | Gera a galeria inteira na marca Wibx |
| `scripts/extract_svg.py` | Tira o SVG de um modelo com ids prefixados (e marcação de animação) |

Exemplo de referência completo e aprovado: deck Cash Management (WiBX, 14 slides). Não vem neste pacote; peça ao autor se precisar.

## Papéis (quem decide o quê)

| Camada | Skill (leia) | Autoridade |
|---|---|---|
| Esqueleto do deck | `vendor/frontend-slides/SKILL.md` | Fluxo, fixed stage 1920×1080, navegação, densidade, export PDF, conversão PPT |
| Direção estética | `vendor/frontend-design/SKILL.md` | Tese visual, tipografia, risco estético justificado |
| Anti-slop / dials | `vendor/taste-skill/design-taste-frontend/SKILL.md` | Dials `DESIGN_VARIANCE`, `MOTION_INTENSITY`, `VISUAL_DENSITY` e pre-flight |
| Acabamento premium | `vendor/taste-skill/high-end-visual-design/SKILL.md` | Espaçamento, double-bezel, física de mola |
| Diagramas | `vendor/diagram-design/SKILL.md` | Tudo dentro de cada diagrama (61 modelos; ver catálogo) |
| Animação | `vendor/gsap-skills/gsap-core/SKILL.md`, `vendor/gsap-skills/gsap-timeline/SKILL.md` (+ `gsap-plugins`, `gsap-performance`) | Coreografia por slide |
| Deck existente | `vendor/taste-skill/redesign-existing-projects/SKILL.md` | Só quando o usuário traz um HTML/deck pronto |

Conflito: Manual da Marca > `frontend-slides` (estrutura) > `frontend-design` + `high-end-visual-design` (visual) > `diagram-design` (dentro do diagrama) > GSAP (movimento).

## Fase 0: Briefing

1. Leia `vendor/frontend-slides/SKILL.md`, siga Phase 0/1 (modo A/B/C, conteúdo, público, densidade). Deck com muito texto = leitura (densidade alta); palestra = baixa.
2. Infira público (engineer / mixed / executive) e nível de animação.
3. Declare em uma linha o "design read" e os dials. Padrão corporativo premium: `VARIANCE 6 · MOTION 6 · DENSITY 3` (leitura: DENSITY 5).

## Fase 0.5: Marca

Deck Wibx usa o **Manual da Marca** (escopo de decks da skill `wibx-brand`), nunca o tema Admin Dashboard (`#00ff70`, Red Hat Display), que é de UI de produto.

1. Leia `../wibx-brand/references/manual.md` INTEIRO: é lei (cores, fontes, logo, área de segurança, proibições).
2. Logo oficial sempre (nunca redesenhe): `../wibx-brand/assets/manual/logo-light.svg`, embutido pelo `build.py` como `%%LOGO%%`. Símbolo isolado: mesmo SVG com `viewBox` recortado (`%%SYMBOL%%`). Clash Display pela CDN da Fontshare (os woff2 não são redistribuídos).
3. Diagramas na marca: `python3 scripts/brand_gallery.py <projeto>/diagramas` (mapa em `assets/diagram-map.json`). O script lista HEX sem mapeamento: complete até zerar. Nunca grave dentro da pasta da skill.
4. Outra marca que não a Wibx: fora do escopo desta skill; o `build.py` e o `qa_static.py` estão presos ao Manual Wibx.

## Fase 1: Direção estética

1. Leia `vendor/frontend-design/SKILL.md` e `vendor/taste-skill/high-end-visual-design/SKILL.md`; tese visual específica ao assunto, dentro do Manual da Marca.
2. Leia `vendor/taste-skill/design-taste-frontend/SKILL.md` como filtro (sem Inter, sem roxo genérico, sem 3 cards iguais, zero travessões).
3. Com o Manual da Marca: declare a direção em uma linha e siga (previews do frontend-slides só se houver liberdade real).

## Fase 2: Diagramas (61 modelos disponíveis)

1. Leia `vendor/diagram-design/SKILL.md` e `references/diagramas.md`. O onboarding de estilo do diagram-design não se aplica: a marca já vem do `brand_gallery.py`.
2. Para cada slide que explica sistema, processo, tempo, hierarquia, comparação ou números, escolha o modelo pela tabela "O slide precisa mostrar...". Prefira diagrama a bullet quando ele ensina mais que o parágrafo. Varie os modelos ao longo do deck (não repita a mesma família em slides seguidos).
3. Leia o `vendor/diagram-design/references/type-<tipo>.md` do modelo (orçamento de nós, regras de conector). Parta do exemplo `-dark` da galeria na marca: `python3 scripts/extract_svg.py <projeto>/diagramas/<exemplo> <prefixo> --anim`.
4. Geometria paramétrica (loop, radial, qualquer coisa com interseção calculada): gere por script (`templates/diagrams.py`, chamado de `<projeto>/parts.py`), nunca chute coordenadas.
5. Regras: 1 a 2 focais em verde/acento; conectores ortogonais com cotovelo r=8; rótulo de seta com máscara e folga de 6 a 10px; legenda em faixa inferior; `<svg role="img">` com `<title>`/`<desc>` prefixados; ids prefixados por diagrama.

## Fase 3: Animação

- `MOTION_INTENSITY` ≤ 4: CSS/WAAPI (`vendor/frontend-slides/animation-patterns.md`).
- ≥ 5 ou diagramas que se desenham: leia `vendor/gsap-skills/gsap-core/SKILL.md` + `vendor/gsap-skills/gsap-timeline/SKILL.md`. GSAP via uma tag CDN (jsDelivr, já no esqueleto). `templates/controller.js`:
  - `[data-r]` reveal de leitura; `[data-seq]` + `.draw` / `.pop` / `.fade` ordem do diagrama; `data-step` no `<section>` = ritmo; `[data-count]` contador (texto no fonte já é o valor final; lições E5).
  - Ponta de seta só aparece quando a linha chega (implementado; lições A2).
  - Pacotes de dados: marque o conector com `data-packet`; o controller faz a bolinha percorrer o caminho real (cotovelos inclusive). Todos os conectores do mesmo caminho recebem `data-packet`. Nunca círculo avulso com `translateX` (lições A7).
  - Receita por família em `references/diagramas.md` (R-FLUXO, R-SEQ, R-BARRA...).
- Objeto animado + sua moldura/brilho no MESMO wrapper; translação no wrapper, rotação só no objeto (lições C1). Objeto recortável vira asset com alfa no build (C2).
- Reduced-motion: quadro final estático. Toda animação precisa de motivo (hierarquia, narrativa, estado).

## Fase 4: Geração e QA (obrigatório, nesta ordem)

**Esqueleto do projeto** (fora da pasta da skill):
```
<projeto>/deck.src.html   copiado de templates/deck.src.html (placeholders %%STAGE_CSS%%, %%CONTROLLER_JS%%, %%LOGO%%, %%SYMBOL%%...)
<projeto>/parts.py        opcional: PARTS = {"NOME": ...} para %%NOME%% (diagramas paramétricos, imagens com alfa)
<projeto>/assets/         imagens de origem
<projeto>/diagramas/      galeria na marca (Fase 0.5)
<projeto>/deck.html       saída arquivo único (é o que se entrega)
```
Fonte só com Edit/Write; scripts só leem o fonte e geram a saída.

1. Leia `references/licoes.md`.
2. `python3 templates/build.py <projeto>` e depois `python3 scripts/qa_static.py <projeto>/deck.html` → precisa dar OK.
3. No navegador: abra o HTML **final** (sirva com `python3 -m http.server`), viewport 1920x1080, injete `scripts/qa_browser.js` via `javascript_tool` e rode `apthtmlQA.run()` → `[]`. Para Venn/zonas: `apthtmlQA.labelsInCircles(...)` com folga ≥ 16px. Sem Claude in Chrome: Chromium headless (lições E6, E7).
4. Para cada slide: captura no meio da animação (≈1,2 s) e no fim (≈4 s). Confira pontas de seta, objetos animados, alinhamento em cards estreitos, espaço morto.
5. Pre-flight do `design-taste-frontend` + checagem de marca (só paleta oficial, fonte oficial, logo oficial, sem uso proibido). Console sem erros. Um teste em viewport de celular (o palco só escala).

## Fase 5: Entrega

- Entregue o caminho do HTML final. Liste o que mudou e **pergunte** sobre divergências de conteúdo/marca encontradas (nunca corrija fato em silêncio).
- Export PDF (Phase 6B do frontend-slides, `vendor/frontend-slides/scripts/export-pdf.sh`) só se pedido.
- NUNCA publique (Vercel, Artifact, URL pública) sem confirmação explícita naquele momento. O `deploy.sh` do frontend-slides não vem neste pacote de propósito.
- Quando o usuário corrigir algo, registre em `references/licoes.md` (o que aconteceu, por quê, regra, como verificar) e, se couber, automatize no QA.
