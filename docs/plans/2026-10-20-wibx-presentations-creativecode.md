# wibx-presentations ← creativecode: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Trazer para `skills/wibx-presentations` o que o pacote `creativecode` (Matheus DOMM, out/2026) tem de novo, sem perder a trava no Manual Wibx nem as correções do #55.

**Architecture:** O `origin/main` (`309c1f9`) é a base e ganha nos conflitos. Do creativecode entram só as partes que servem a deck Wibx: os acréscimos de runtime (controller e stage), as checagens novas de QA, as lições novas com IDs que não colidem, os scripts de PDF e 3D, o padrão Confronto e o ai-website-cloner como referência visual. Nada do creativecode é copiado por cima de arquivo existente: em todo arquivo que mudou nos dois lados o merge é manual.

**Tech Stack:** Python 3 stdlib, JS de navegador (GSAP 3 por CDN), zsh, puppeteer-core (só no QA).

**Spec:** a proposta e as decisões do Pedro na sessão de 2026-10-20, registradas abaixo em "Decisões aprovadas".

**Origem dos arquivos novos:** `/Users/pedroescaleira/Desktop/creativecode/` (abaixo, `$CC`). Skill de destino: `skills/wibx-presentations/` (abaixo, `$SK`). Worktree: `/Users/pedroescaleira/Desktop/wibx-skills-wt/wibx-presentations-creativecode`, branch `feat/wibx-presentations-creativecode`, sem upstream.

## Decisões aprovadas

- Caminho B: merge seletivo, nunca substituir a pasta inteira.
- Modo B (interfaces: app, site, landing, dashboard) fica **fora**.
- Multi-marca fica **fora**. A skill continua presa ao Manual Wibx (`../wibx-brand`). Ficam de fora `extract_brand_kit.py`, `~/.creativecode/brands`, `BRAND.md` e `--brand`.
- O ai-website-cloner entra só como "URL de site como referência visual" do deck.

## Fatos medidos que fixam o plano (sessão de 2026-10-20)

- As skills vendorizadas do creativecode são idênticas às de `$SK/vendor/` (o `diff -rq` mostra só a posição do LICENSE). A única exceção é `frontend-slides/scripts/deploy.sh`, que fica **fora** de propósito (ver `vendor/SOURCES.md`). Resultado: **nenhuma mudança em `vendor/` além do ai-website-cloner**.
- `gsap-scrolltrigger`, `gsap-react`, `gsap-frameworks` e `gsap-utils` só são usados pelo Modo B no `$CC/SKILL.md` (linhas 25, 62 e 162), então ficam **fora**.
- `wibx-brand` não entrega ícones (só `assets/manual/logo-*.svg`), então `kit.inline_icons` e `icon-anim.*` não têm entrada Wibx. **Fora: `kit.py`, `icon-anim.css`, `icon-anim.js`.** O 3D embute os bytes do WebP pelo `raw_data_uri` do `build.py` (Task 6).
- O `qa_static.py` do creativecode (com B5 e C3) roda no deck do template Wibx sem falso positivo: `QA estático: OK (5 slides)`.
- `$CC/scripts/check_verbatim.py` lê `ROOT/source/proposta.txt`, com ROOT = pasta do script, e tem o deck padrão `Uau-Caixa-Blockchain-Governance.html`. É ferramenta por projeto e por isso vai para `templates/`.
- `$SK/templates/stage.css` tem `@media print`, mas não tem `@page`. O `export_pdf.sh` exige `@page { size: 1920px 1080px; margin: 0 }`.
- Nesta máquina não há Chrome nem Chromium em `/Applications` ou `~/Applications` (busca por `mdfind` vazia), nem ffmpeg, Blender ou Pillow no `python3`. `pdfseparate` e `sips` existem.
- O bump de versão é o que faz o updater puxar conteúdo novo (commit `c4060f2`). O `plugin.json` está em `0.4.0` e nem o #54 nem o #55 subiram a versão.

## Global Constraints

- O nome da skill continua `wibx-presentations`, e o frontmatter tem que passar no `scripts/quick_validate.py`.
- Nunca gravar arquivo de teste dentro de `$SK`, porque o `package_skill.py` empacota a pasta inteira. Fixtures ficam em `$(mktemp -d)`.
- Mantêm-se: o namespace `apthtmlQA`, a chave `apthtml-edits-${SLUG}-v1` do localStorage (trocar apaga as edições salvas de quem já usa) e o cabeçalho "APTHTML" nos arquivos.
- Texto do creativecode que for portado troca `creativecode`/`CREATIVECODE` por `apthtml`/`APTHTML`, `<SKILL_DIR>/skills/` por `vendor/...` e `BRAND.md` por "Manual da Marca (`../wibx-brand/references/manual.md`)".
- Zero travessão (— ou –) no texto novo (lições D2).
- Uma mudança por commit, com mensagem no padrão `feat(wibx-presentations): ...` ou `fix(...)` e o rodapé `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- O critério de aceite é `exit 0` do comando de verificação de cada task. Revisão por LLM não substitui.

## Review Focus

1. **Deck sem GSAP** (CDN fora): os contadores mostram o valor final (E5) e o hook não roda. Teste na Task 1.
2. **Deck aberto em iframe sandbox** (`history.replaceState` lança erro): a navegação continua funcionando. Teste na Task 1.
3. **Mock de celular com a fonte do sistema** (E8/H2) com `data-qa-ignore`: o D4 não acusa. Sem o atributo, acusa. Teste na Task 3.
4. **Deck antigo, já entregue, com edições salvas**: a chave do localStorage não muda. Teste na Task 1 (grep).
5. **Máquina sem Google Chrome no caminho padrão**: o `export_pdf.sh` aceita `CHROME=` e, sem navegador, sai com erro claro em vez de falhar calado. Teste na Task 5.

---

### Task 0: Ambiente de QA (sem commit)

Decisão do Pedro (2026-10-20): **sem instalação, sem asset 3D real e sem deck real por agora.** Esta máquina não tem Chromium, ffmpeg, Blender nem Pillow (ver "Fatos medidos").

- [ ] **Step 1: Navegador.** Usar o Claude in Chrome se ele estiver conectado (não exige instalação), rodando `javascript_tool` na aba do deck servido por `python3 -m http.server`. Sem ele, toda checagem "no navegador" deste plano fica **NÃO VERIFICADA** e entra no PR. Não baixar navegador.
- [ ] **Step 2:** Daqui em diante, "rodar no navegador `<expr>`" significa avaliar `<expr>` no deck servido em viewport 1920×1080.

### Task 1: Runtime: `stage.css` e `controller.js`

**Files:**
- Modify: `$SK/templates/stage.css`
- Modify: `$SK/templates/controller.js`
- Commit também: `docs/plans/2026-10-20-wibx-presentations-creativecode.md` (este plano)

**Interfaces:**
- Produces: a classe `.grow` (`data-grow="y"` cresce de baixo para cima); `data-hook="nome"` no `<section>`, que chama `window.deckHooks.nome(slide, gsap)` e devolve `Timeline[]` (essas timelines morrem ao trocar de slide); a classe `.active` no slide visível, já existente.

- [ ] **Step 1: Montar a fixture.** `FX=$(mktemp -d)/fx`; copiar `$SK/templates/deck.src.html` para `$FX/`. Antes de `<nav class="deck-controls"`, inserir:

```html
<section class="slide" data-hook="probe"><svg class="dg" role="img" aria-labelledby="pb-t pb-d" viewBox="0 0 400 100" width="400" height="100"><title id="pb-t">probe</title><desc id="pb-d">probe</desc><rect id="pb-bar" class="grow" data-seq="1" x="0" y="0" width="400" height="40" fill="#22ff7b"/></svg><p data-count="4000">0</p></section>
```

Logo antes de `<script>\n%%CONTROLLER_JS%%`, inserir `<script>window.deckHooks={probe:(s,g)=>{window.__probe=(window.__probe||0)+1;return [];}};</script>`.

- [ ] **Step 2: Rodar contra a base e ver falhar.** `python3 $SK/templates/build.py $FX && python3 -m http.server -d $FX 8765`. No navegador, ir até o último slide e conferir que `window.__probe` é `undefined`. FAIL esperado, porque a base não tem hooks.

- [ ] **Step 3: Implementar em `stage.css`.**
  - Manter as duas linhas de `border-box` (lições B7).
  - Acrescentar, verbatim do `$CC/templates/stage.css`, a regra `.slide:not(.active) *... { animation-play-state: paused !important; }` e o comentário do grão.
  - No `@media (prefers-reduced-motion: reduce)`, trocar `transition-duration: 0.2s !important` por `transition: none !important`, com o comentário citando lições E13.
  - Dentro de `@media print`, acrescentar `@page { size: 1920px 1080px; margin: 0; }`.

- [ ] **Step 4: Implementar em `controller.js`.** A base é o arquivo atual. Trazer do `$CC/templates/controller.js` três coisas:
  - o `try { history.replaceState(...) } catch (e) {}`;
  - o ramo `else if (el.classList.contains('grow'))`;
  - o bloco do hook (com o comentário que cita lições C3), colocado antes do laço de `[data-count]`.

  Não trazer: a troca do dasharray (o atual usa `` `${len} ${len}` ``, lições A8), a remoção do `fmt` e do fallback sem GSAP, nem a troca da chave e do cabeçalho.

- [ ] **Step 5: Verificar.** Rebuild e servir. No navegador, depois de ir ao último slide e esperar 3 s:
  - `window.__probe === 1`;
  - `getComputedStyle(document.getElementById('pb-bar')).transform` sem `scaleX(0)`, ou seja, `matrix(1, 0, 0, 1, 0, 0)` ou `none`;
  - o `<p data-count>` mostra `4.000`;
  - `apthtmlQA.run()` devolve `[]`, depois de injetar `$SK/scripts/qa_browser.js`.

  Review Focus 1: recarregar com o `<script src=...gsap...>` removido da fixture e conferir que `<p data-count>` mostra `4.000` e que `window.__probe` é `undefined`.

  Review Focus 2: avaliar `history.replaceState=()=>{throw new Error('sandbox')}` e depois apertar a seta para a direita. O contador `#count` tem que mudar e o console não pode mostrar erro sem tratamento.

  Review Focus 4: `grep -c 'apthtml-edits-' $SK/templates/controller.js` = 1 e `grep -c 'strokeDasharray: `${len} ${len}`' $SK/templates/controller.js` = 1.

  Por fim, `python3 $SK/scripts/qa_static.py $FX/deck.html` termina com exit 0.

- [ ] **Step 6: Commit.** `git add docs/plans/2026-10-20-wibx-presentations-creativecode.md $SK/templates/stage.css $SK/templates/controller.js && git commit -m "feat(wibx-presentations): hooks de slide, .grow, pausa fora do slide ativo e @page"`

### Task 2: `qa_static.py`: checagens B5 e C3 com selftest

**Files:**
- Modify: `$SK/scripts/qa_static.py`

**Interfaces:**
- Produces: `strip_at_blocks(css: str) -> str`; a flag de CLI `--selftest`, que sai com 0 se todos os casos passam.

- [ ] **Step 1: Escrever o selftest falhando.** Acrescentar `--selftest` ao argparse e uma função `selftest() -> int` com quatro casos. Cada caso monta um HTML mínimo e roda as checagens com `--no-palette` implícito:
  - `.a{x:1}` duas vezes num `<style>` resulta em uma falha contendo `[B5] classe .a`;
  - `.a{}` mais `@media print{.a{}}` não gera falha B5;
  - `.slide{}` duas vezes não gera falha (framework);
  - um `<section data-hook="h">` com `<div class="x" data-r>` e um script `window.deckHooks.h = (slide, g) => {\n const el = slide.querySelector('.x');\n g.set(el, {});\n};` (a regex exige `deckHooks.h =` seguido de `\n};`) resulta em uma falha contendo `[C3] .x`.

  Para isso, extrair o corpo das checagens de `main()` para `check(src: str, palette: bool) -> list[str]`, que `main()` e `selftest()` chamam.

- [ ] **Step 2: Rodar e ver falhar.** Run: `python3 $SK/scripts/qa_static.py --selftest`. Expected: FAIL, porque os casos B5 e C3 ainda não acusam.

- [ ] **Step 3: Implementar.** Portar do `$CC/scripts/qa_static.py`, verbatim, `strip_at_blocks` e os blocos `# B5` e `# C3` para dentro de `check()`. Manter `MANUAL`, `brand_palette()` e `--no-palette` da base. Atualizar a docstring com `B5` e `C3`.

- [ ] **Step 4: Verificar.** `python3 $SK/scripts/qa_static.py --selftest` termina com exit 0. A fixture da Task 1 (rebuild) passa com exit 0 em `python3 $SK/scripts/qa_static.py $FX/deck.html`.

- [ ] **Step 5: Commit.** `fix(wibx-presentations): qa_static acusa colisão de classe (B5) e dono duplo de animação (C3)`

### Task 3: `qa_browser.js`: decoração ignorada, `data-max-lines` e `textInShapes`

**Files:**
- Modify: `$SK/scripts/qa_browser.js`

**Interfaces:**
- Produces: `apthtmlQA.textInShapes(groupSel = 'svg g.pop') -> string[]`; o atributo `data-qa-ignore`, que tira o elemento e tudo dentro dele do QA; `data-max-lines="N"` em título.
- Consumes: a fixture da Task 1.

- [ ] **Step 1: Acrescentar à fixture** um slide com três peças:
  - `<div style="position:absolute;left:1800px;top:10px;width:400px;height:40px" data-qa-ignore>x</div>`, que vaza do palco;
  - `<span style="font-family:-apple-system,sans-serif" data-qa-ignore>09:41</span>`, com fonte fora do manual (não usar `<pre>`: o template do #55 já o força em Clash Display);
  - um `<svg class="dg" ...><g class="pop"><rect x="0" y="0" width="100" height="40"/><text x="10" y="80">fora</text></g></svg>`, com o `<title>`/`<desc>` prefixados exigidos pelo A4.

- [ ] **Step 2: Rodar e ver falhar.** No navegador, injetar `qa_browser.js` e rodar `apthtmlQA.run()`. Expected: FAIL, com "fora do palco" e "texto fora da fonte do manual: span". `apthtmlQA.textInShapes` é `undefined`.

- [ ] **Step 3: Implementar.** Portar do `$CC/scripts/qa_browser.js`: `IGNORE` e `ignored()`, aplicados em B*, B2 (com o `ownText` e o pulo de filho ignorado) e B4. Aplicar `ignored(el)` também em **B8, B9 e D4**, que só existem na base. Portar também `data-max-lines` e `textInShapes`, com o comentário apontando lições **A9** (renumerada na Task 4). Manter `BRAND_FONT`, B8, B9, D4, o namespace e a linha sobre o `qa_headless.mjs`. O cabeçalho passa a citar `B2, B3, B4, B8, B9, D4, A1, A9`.

- [ ] **Step 4: Verificar.** `apthtmlQA.run()` devolve `[]` e `apthtmlQA.textInShapes()` devolve `['texto fora da forma: "fora"']`. Review Focus 3: tirar o `data-qa-ignore` do `<span>`, rebuild, e `run()` tem que acusar `texto fora da fonte do manual: span`.

- [ ] **Step 5: Commit.** `feat(wibx-presentations): qa_browser com data-qa-ignore, data-max-lines e textInShapes`

### Task 4: `licoes.md`: juntar e renumerar

**Files:**
- Modify: `$SK/references/licoes.md`
- Modify: qualquer arquivo de `$SK` que cite um ID renumerado (no fim da Task 5 o grep do Step 3 é refeito)

**Interfaces:**
- Produces: IDs estáveis. Todo ID da base se mantém. As lições do creativecode entram com o ID da tabela abaixo; as que não aparecem nela mantêm o próprio ID, porque não colidem.

| creativecode | Destino |
|---|---|
| A4 "Self-check reprova o deck" | **funde** na A4 da base (mesmo incidente): acrescentar a linha do `verify-geometry.py` |
| B5 (versão com `.track`) | **substitui** o texto da B5 da base (extensão do mesmo incidente) |
| A8 "Texto saindo do nó" | **A9** |
| D4 "Comparativo com concorrente" | **D7** (a D5 do creativecode, se citar "D4", passa a citar D7) |
| E3 "Hook de guarda bloqueia shell" | **E15** |
| E5 "Tradutor automático" | **E16** |
| E6 "PDF retângulo escuro no Preview" | **E17** |
| E7 "Trocar a fonte de deck pronto" | **E18** |
| E9 "Kit de marca em PSD/PSB/AI" | **fora** (multi-marca) |
| H3 "Ícones da marca animados" | **fora** (`icon-anim` fora) |
| L-HIDDEN "overlay ... site de campanha" | **fora** (Modo B) |

- [ ] **Step 1: Escrever a verificação** (descartável, num arquivo em `mktemp -d`) que falha hoje: um `python3 -c` que (1) lista os IDs `^### ([A-H]\d+)\.` de `licoes.md` e falha se algum se repetir; (2) acha `(lições|licoes\.md) ([A-H]\d+)` (inclusive em listas como `lições E6/E10`, `A2, B7` e `licoes.md E6 e E10`) em `$SK/**/*.{md,py,js,css,sh,html}`, fora de `vendor/`, e falha se algum ID citado não existir em `licoes.md`.

- [ ] **Step 2: Juntar.** Seguir a ordem das seções da base (A a E). Acrescentar as seções F, G e H do creativecode. Pôr cada lição nova na sua seção, com o ID da tabela. Nas lições trazidas, aplicar as trocas de texto das Global Constraints e ajustar as remissões internas entre elas para os IDs novos. Na E8 e na H2, acrescentar: "Mock de tela de sistema leva `data-qa-ignore` (o D4 do `qa_browser.js` não o checa)". Onde a lição citar `kit.raw_data_uri`, trocar por "`raw_data_uri` do `templates/build.py` no `parts.py` (nunca reprocessar com PIL)". Na E11, tirar o parágrafo "Ícones da marca animados" (`icon-anim` fora); o resto da E11 fica.

- [ ] **Step 3: Verificar.** A verificação do Step 1 termina com exit 0, e `grep -c '^### ' $SK/references/licoes.md` é igual ao número de IDs únicos.

- [ ] **Step 4: Commit.** `feat(wibx-presentations): lições do creativecode, com IDs que não colidem`

### Task 5: Arquivos novos: PDF, Confronto e check_verbatim

**Files:**
- Create: `$SK/scripts/export_pdf.sh` (copiado de `$CC/scripts/`)
- Create: `$SK/templates/duel-slide.html`, `$SK/templates/duel.css`, `$SK/templates/duel-hook.js` (de `$CC/templates/`)
- Create: `$SK/templates/check_verbatim.py` (de `$CC/scripts/check_verbatim.py`)

**Interfaces:**
- Consumes: os hooks da Task 1; as lições E17 e E10 da Task 4.
- Produces: `export_pdf.sh <Deck.html> [páginas...]`, que gera o `<Deck>.pdf` ao lado do HTML e respeita `CHROME=`; o hook `deckHooks.duel`; `check_verbatim.py <deck.html>` (argumento obrigatório), que lê `<pasta do script>/source/proposta.txt`.

- [ ] **Step 1: Copiar** os cinco arquivos e aplicar as trocas de texto das Global Constraints. No `export_pdf.sh`: `OUT=${TMPDIR:-/tmp}/apthtml-pdf`, `CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}` e, antes do primeiro uso, `[ -x "$CHROME" ] || { echo "Chrome não encontrado: defina CHROME=<caminho>" >&2; exit 2; }`. Trocar a remissão "E6" por "E17". No `check_verbatim.py`: remover o default `Uau-Caixa-...html`; sem argumento, imprimir a docstring e sair com 2. No `duel.css`: trocar `var(--mono)` por `'Clash Display', sans-serif` (D4) e usar só HEX do Manual (D1).

- [ ] **Step 2: Fixture do Confronto.** Numa fixture nova (`FX2`, cópia de `deck.src.html`), colar o `<section>` de `duel-slide.html`, o CSS de `duel.css` no `<style>` e o `duel-hook.js` num `<script>` antes do controller. Criar `FX2/parts.py` com `PARTS = {"ETH_LOGO": '<svg viewBox="0 0 10 10" aria-hidden="true"><rect width="10" height="10" fill="currentColor"/></svg>'}`, mais o que o `duel-slide.html` exigir (por exemplo `#i-clock`) como símbolos mínimos.

- [ ] **Step 3: Verificar.**
  - `python3 $SK/templates/build.py $FX2` e `python3 $SK/scripts/qa_static.py $FX2/deck.html` terminam com exit 0.
  - No navegador, no slide do duel: `apthtmlQA.run()` devolve `[]`; e, comparando 1 s com 8 s após a entrada, o texto de `.duel-clock b` mudou (o hook roda).
  - `zsh -n $SK/scripts/export_pdf.sh` e `python3 -m py_compile $SK/templates/check_verbatim.py` terminam com exit 0.
  - check_verbatim: com `FX/source/proposta.txt` contendo o texto visível da fixture, `python3 $SK/templates/check_verbatim.py $FX/deck.html` (copiado para `$FX`) termina com exit 0; com uma palavra trocada no `.txt`, exit 1.
  - Review Focus 5: `CHROME=/nao/existe $SK/scripts/export_pdf.sh $FX/deck.html` termina com exit 2 e mostra a mensagem.
  - Se a Task 0 deu um navegador por caminho, `CHROME=<ele> $SK/scripts/export_pdf.sh $FX/deck.html` gera o PDF, e `pdfinfo` mostra `Page size: 1440 x 810 pts` (1920×1080 px) com uma página por slide. Sem navegador, isso fica **NÃO VERIFICADO** e entra no PR.
  - Refazer a verificação da Task 4, Step 1, que tem que continuar com exit 0.

- [ ] **Step 4: Commit.** `feat(wibx-presentations): export de PDF, padrão Confronto e check_verbatim`

### Task 6: Objeto 3D: conversores e embed sem reprocessar

**Files:**
- Create: `$SK/scripts/blender_to_webp.py`, `$SK/scripts/frames_to_webp.py`, `$SK/scripts/video_to_webp.py` (de `$CC/scripts/`, só com as trocas de texto das Global Constraints e o venv `~/.venvs/apthtml` no lugar de `~/.venvs/creativecode`)
- Modify: `$SK/templates/build.py` (acrescentar `raw_data_uri`)

**Interfaces:**
- Consumes: as lições C1, E11, H4, H9 e H10 da Task 4.
- Produces: `raw_data_uri(path: Path) -> str` em `templates/build.py`, que devolve um data URI com os **bytes originais** do arquivo, sem PIL. O mime de `.webp`, `.gif` e `.png` é fixado explicitamente. O `parts.py` do projeto importa com `from build import raw_data_uri` (o `project_parts` já põe `templates/` no `sys.path`).

- [ ] **Step 1: Verificação que falha.** Num `mktemp -d`, gravar `x.webp` com bytes arbitrários (`b"RIFF\x00\x00\x00\x00WEBPVP8X" + bytes(range(256))`) e rodar `python3 -c "import sys; sys.path.insert(0, '$SK/templates'); from pathlib import Path; from build import raw_data_uri; import base64; u = raw_data_uri(Path('x.webp')); assert u.startswith('data:image/webp;base64,'); assert base64.b64decode(u.split(',', 1)[1]) == Path('x.webp').read_bytes(); print('ok')"`. Expected: FAIL com `ImportError`.
- [ ] **Step 2: Implementar** `raw_data_uri` em `build.py` (perto de `alpha_circle_webp`) e copiar os três conversores.
- [ ] **Step 3: Verificar.**
  - O comando do Step 1 imprime `ok`.
  - `python3 -m py_compile` nos três conversores termina com exit 0.
  - O baseline continua igual: `python3 $SK/templates/build.py <cópia de deck.src.html>` e `qa_static.py` terminam com exit 0.
  - **NÃO VERIFICADO, declarado no PR:** a execução dos conversores (sem ffmpeg, Blender nem Pillow, por decisão do Pedro), a qualidade com asset real e o `qa_webp3d.py`. O QA do 3D fica como trabalho seguinte, quando as dependências e o asset vierem.
- [ ] **Step 4: Commit.** `feat(wibx-presentations): conversores de objeto 3D e raw_data_uri (embed sem reprocessar)`

### Task 7: `vendor/ai-website-cloner` e `SOURCES.md`

**Files:**
- Create: `$SK/vendor/ai-website-cloner/{README.md,LICENSE,clone-website/SKILL.md,clone-website/references/inspection-guide.md,clone-website/references/framer-and-motion.md}` (de `$CC/vendor/ai-website-cloner/`)
- Modify: `$SK/vendor/SOURCES.md`

- [ ] **Step 1: Achar a origem.** `cd "$(mktemp -d)" && git clone https://github.com/JCodesMore/ai-website-cloner-template`. Achar o commit mais recente em que os arquivos copiados batem com o `$CC` (por `git log` no caminho da skill e `diff`). Registrar o SHA e o recorte.
- [ ] **Step 2: Auditar.** Rodar a skill `security-audit` no clone. Se houver achado HIGH ou CRITICAL nos arquivos copiados: parar e reportar ao Pedro, sem copiar.
- [ ] **Step 3: Copiar e registrar.** Acrescentar uma linha à tabela do `SOURCES.md`, com Pasta, Origem, Commit e Recorte ("só markdown da skill clone-website; o projeto Next.js não vem"), e a data e o resultado do audit no parágrafo do topo. Se o SHA não for achado, escrever `commit não identificado (cópia do pacote creativecode, 2026-10)` e levar isso ao PR como **NÃO VERIFICADO**.
- [ ] **Step 4: Verificar.** `diff -r $CC/vendor/ai-website-cloner $SK/vendor/ai-website-cloner` vazio e `python3 scripts/validate_refs.py skills/wibx-presentations` com exit 0.
- [ ] **Step 5: Commit.** `feat(wibx-presentations): ai-website-cloner vendorizado (referência visual de site)`

### Task 8: `SKILL.md`, `diagramas.md` e `MANUAL.md`

**Files:**
- Modify: `$SK/SKILL.md`, `$SK/references/diagramas.md`, `$SK/MANUAL.md`

**Interfaces:**
- Consumes: os nomes e IDs das Tasks 1 a 7.

- [ ] **Step 1: `SKILL.md`.** A base é o arquivo atual. Acréscimos, nesta ordem:
  - **Frontmatter `compatibility`:** acrescentar "Opcional: Google Chrome + poppler (`pdfseparate`) para PDF no macOS; ffmpeg, Blender e, no venv `~/.venvs/apthtml`, Pillow, numpy e psd-tools para objeto 3D."
  - **Tabela "Arquivos":** uma linha para `scripts/export_pdf.sh`, uma para `scripts/{blender,frames,video}_to_webp.py`, uma para `templates/duel-*`, uma para `templates/check_verbatim.py` e uma para `vendor/ai-website-cloner/`.
  - **Tabela "Papéis":** a linha "Site de referência | `vendor/ai-website-cloner/clone-website/SKILL.md` | Como observar e medir um site citado como referência".
  - **Fase 0.5, item 5:** o fluxo "URL de site como referência" do `$CC/SKILL.md`, passos 1 a 4, com a regra: o Manual Wibx continua lei; um site de terceiro inspira ritmo, composição e movimento, nunca cor, fonte ou logo.
  - **Fase 3:**
    - `.grow` (R-BARRA);
    - `data-hook` e o padrão Confronto (lições C3, D5; barras nunca como peça principal de comparativo);
    - entrada por slide com `.slide.active`;
    - "o export de PDF liga reduced-motion: o quadro 0 é a pose do PDF";
    - objeto 3D, como subseção própria da Fase 3:
      1. perguntar primeiro pelo arquivo 3D, na ordem `.blend` > quadros > vídeo (H10); giro 2D (`rotateY` numa imagem chapada) foi rejeitado (E11);
      2. converter com o script do tipo e os parâmetros de H9 e H10;
      3. folha de contato com todos os quadros sobre fundo claro, mostrada ao usuário (H9);
      4. embutir com `raw_data_uri` no `parts.py` (nunca reprocessar com PIL);
      5. o wrapper de C1;
      6. objeto sozinho, sem base nem camada translúcida (H4).
  - **Fase 4:**
    - no passo 3: `data-qa-ignore`, `apthtmlQA.textInShapes()` e `document.getAnimations()` para aba oculta (E12);
    - passo novo: coerência dos dados de exemplo (H1/H2);
    - passo novo: peso de até ~8 MB;
    - passo novo: deck feito a partir de documento do cliente roda o `check_verbatim.py` (G1).
  - **Fase 5:** trocar a linha do export do frontend-slides por `scripts/export_pdf.sh <deck.html> [páginas]` (lições E17, E10). Depois do primeiro pedido de PDF, entregar HTML e PDF juntos.
  - **Nada** de Modo B, `BRAND.md`, `~/.creativecode`, `kit.py`, ícones animados ou WELCOME.
- [ ] **Step 2: `diagramas.md`.** Acrescentar a seção "Padrões de slide próprios (Confronto)" do `$CC` (com caminhos `templates/duel-*`) e trocar o texto da R-BARRA pela versão com `.grow`. Os caminhos de `vendor/` e o `brand_gallery.py <projeto>/diagramas` da base ficam como estão.
- [ ] **Step 3: `MANUAL.md`.** Um bullet em EN e outro em PT para cada item: export de PDF fiel ao Preview, padrão Confronto e objeto 3D girando.
- [ ] **Step 4: Verificar.** `python3 scripts/quick_validate.py skills/wibx-presentations` e `python3 scripts/validate_refs.py skills/wibx-presentations` terminam com exit 0; a verificação da Task 4, Step 1, também; e `grep -rniE 'creativecode|BRAND\.md|\.creativecode' $SK --include='*.md' --include='*.py' --include='*.js' --include='*.css' --include='*.sh' --include='*.html'` não retorna nada.
- [ ] **Step 5: Commit.** `docs(wibx-presentations): SKILL, catálogo e manual com o que veio do creativecode`

### Task 9: Pacote, versão, CI local e PR

**Files:**
- Modify: `packages/wibx-presentations.skill` (gerado)
- Modify: `.claude-plugin/plugin.json` (`"version": "0.4.0"` passa a `"0.5.0"`)

- [ ] **Step 1:** `python3 scripts/package_skill.py skills/wibx-presentations packages`
- [ ] **Step 2:** Bump para `0.5.0` em `.claude-plugin/plugin.json` (Review Focus: sem o bump, quem já tem a skill instalada não recebe a atualização, conforme `c4060f2`).
- [ ] **Step 3: CI local** (os mesmos passos do `.github/workflows/ci.yml`), cada um com exit 0: o `quick_validate.py` de todas as skills; o README indexando todas as skills; `packages/` em sincronia (`package_skill.py` num tmp e `cmp`); `python -m json.tool .claude-plugin/*.json`; `python -m compileall -q scripts`.
- [ ] **Step 4: Deck real, ponta a ponta.** Fora por decisão do Pedro (2026-10-20): fica **NÃO VERIFICADO** em destaque no PR. Quando houver um deck real, fazer o rebuild com a skill nova, rodar `qa_static.py` (exit 0) e `apthtmlQA.run()` (`[]`), e capturar os slides no meio (1,2 s) e no fim (4 s), comparando com as capturas da versão `309c1f9`.
- [ ] **Step 5: Commit.** `chore(wibx-presentations): reempacota o .skill e sobe o plugin para 0.5.0`
- [ ] **Step 6: Gate do Pedro.** Mostrar `git log --oneline origin/main..HEAD` e `git diff --stat origin/main`. Fazer **push e PR só com o OK dele, dado nessa hora**. O PR tem revisor Caio Maciel (autor do #54 e do #55) e corpo no formato fixo: o que muda · fatos medidos · NÃO VERIFICADO (execução e qualidade do 3D, PDF real, checagens de navegador se o Claude in Chrome não estava conectado, deck real se faltou, SHA do cloner se não achado) · quem pode quebrar (quem usa `/wibx-presentations` pelo plugin; decks em andamento) · rollback (`git revert` do merge do PR e o bump de volta para 0.4.0 em outro PR).

## Rollback

- Antes do merge: apagar a branch e o worktree com `git -C ~/Desktop/wibx-skills worktree remove <worktree> && git -C ~/Desktop/wibx-skills branch -D feat/wibx-presentations-creativecode`. Nada fora do worktree é tocado.
- Depois do merge: `git revert -m 1 <merge>` num PR novo, junto com um bump para `0.5.1`. A versão instalada nas máquinas só muda quando o plugin atualiza.
