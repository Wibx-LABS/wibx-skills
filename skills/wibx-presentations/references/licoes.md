# Lições aprendidas (erros reais, corrigidos com o usuário)

Origem: deck Cash Management / WiBX (2026-09-23), via pacote apthtml. Itens E5 a E7 do porte para esta skill (2026-09-24).
A9, a 2ª ocorrência da B5, C3, D5 a D7, E8, E10 a E18 e as seções F a H vêm do pacote creativecode (Matheus DOMM, out/2026; decks de tokenização, cashback, proposta comercial e Melhor Dia 2K27), trazidas em 2026-10-20 com IDs que não colidem com os daqui. A frase da A4 do creativecode (o self-check do diagram-design reprova o deck inteiro) foi fundida na A4.
Cada item: o que aconteceu, por que, a regra, e como verificar. Leia antes da Fase 4.

---

## A. Diagramas

### A1. Rótulo de conjunto cruzando o traço do círculo vizinho (Venn)
- **Aconteceu:** "Prova imutável" e "Custo sob demanda" encostavam no contorno de outro círculo.
- **Por quê:** posição escolhida no olho, sem medir a caixa real do texto.
- **Regra:** todo rótulo dentro de região (Venn, quadrante, zona) precisa ter os 4 cantos da `getBBox()` **dentro** do próprio conjunto e **fora** dos demais, com folga ≥ 16px do traço. Mesmo tamanho de fonte para rótulos simétricos.
- **Verificar:** `scripts/qa_browser.js` → `apthtmlQA.labelsInCircles(svg, circles, labels)`; se falhar, varra posições (x, y, fonte) e escolha a de maior folga.

### A2. Ponta da seta aparece antes da linha chegar
- **Aconteceu:** marcadores (`marker-end`) ficavam visíveis parados enquanto a linha ainda se desenhava.
- **Por quê:** `stroke-dasharray/offset` esconde só o traço; o marcador é renderizado independente.
- **Regra:** em toda linha animada com draw, remova `marker-end` no início da timeline e recoloque via `tl.call()` em `at + dur * 0.96`. Já implementado em `templates/controller.js`.
- **Verificar:** screenshot NO MEIO da animação (≈1,2 s após entrar no slide), não só no fim.

### A3. Raios do loop curtos / invisíveis
- **Por quê:** hub largo + raio do anel pequeno deixam só ~20px de raio diagonal.
- **Regra:** geometria paramétrica em `templates/diagrams.py` (chamada pelo `parts.py` do projeto); após gerar, confira que cada raio tem ≥ 40px visíveis. Ajuste `R` antes de encolher o hub.

### A4. Contrato de acessibilidade só nos SVGs de diagrama
- **Por quê:** validar o deck inteiro como se fosse um diagrama conta logos, ícones e scripts. O self-check do diagram-design (`vendor/diagram-design/scripts/self_check.py`) espera um arquivo com UM diagrama e reprova o deck inteiro.
- **Regra:** valide o contrato (role=img, `<title>` primeiro filho, ids prefixados, aria-labelledby title+desc) só nos SVGs de diagrama. `qa_static.py` faz isso.
- **Por diagrama:** o `verify-geometry.py` do repositório do diagram-design continua valendo (máscara de rótulo sobre nó, regra 6 da §6 do `vendor/diagram-design/SKILL.md`). Ele só existe no checkout do repositório, não em `vendor/diagram-design/`.

### A5. Diagramas: remover slide antigo deixou restos
- **Regra:** substitua seções inteiras com um único Edit (texto exato lido com Read); nunca comente blocos com `<!-- -->` (comentários internos quebram). Depois, `qa_static.py` acusa ids duplicados.

### A7. Pacote de dados só em uma das linhas do caminho
- **Aconteceu:** na arquitetura, a bolinha só saía na linha do Débito; Crédito e Ajustes (linhas com cotovelo) ficavam sem.
- **Por quê:** pacotes eram círculos soltos animados com `translateX`, que só anda em linha reta; desenhei só onde a reta coincidia. A bolinha não sabia qual caminho seguir.
- **Regra:** pacote nunca é um elemento avulso. Marque o conector com `data-packet` e o controller gera a bolinha percorrendo o path real (`getPointAtLength`), depois que a linha se desenha. Todos os conectores do mesmo caminho (mesma cor/papel) recebem `data-packet`, inclusive os com cotovelo. Proibido `translateX`/`--d` para mover pacote.
- **Verificar:** `qa_static.py` acusa caminho parcial (um conector com `data-packet` e outro irmão da mesma cor sem) e pacote legado (`class="packet"`, `translateX`). No navegador, amostre `cx/cy` das `.packet-dot` por 3 s: cada uma deve cobrir o path inteiro (passar pelos cotovelos).

### A8. Conector tracejado aparece inteiro antes da hora
- **Aconteceu:** no deck Maestro (2026-09-29), conectores com `stroke-dasharray="6 5"` e classe `.draw` apareciam desenhados no primeiro quadro, segundos antes da vez deles.
- **Por quê:** o controller escrevia `strokeDasharray: len` (um valor só). Com tracejado já no atributo, o GSAP troca só o primeiro número: `"6 5"` vira `"702px, 5px"`. Com deslocamento 702, o traço aparece depois de um vão de 5px. Reproduzido num deck mínimo: o path sólido fica oculto, o tracejado não.
- **Regra:** o controller escreve `strokeDasharray: \`${len} ${len}\`` (dois valores). O `clearProps` devolve o tracejado original quando o desenho termina. Já implementado em `templates/controller.js`.
- **Verificar:** captura no meio da animação (E2) de slide com conector tracejado; nada tracejado antes do seu `data-seq`.

### A6. Galeria recolorida: fonte da marca pode ser mais larga que a Geist
- **Regra:** depois de `brand_gallery.py`, sirva a pasta por HTTP (`python3 -m http.server`) e meça em iframes (mesma origem) se cada `<text>` cabe no menor `<rect>` que o contém, após `document.fonts.ready`. Confirme que a fonte da marca carregou (`document.fonts.check`) antes de confiar no resultado. WiBX/Clash Display: 1 estouro em 61 modelos, e ele já existia no original (texto mono).
- **Ao extrair um modelo para o slide:** remova o `<rect>` de fundo de tela cheia do exemplo (o slide já tem fundo e brilho).

### A9. Texto saindo do nó do fluxograma (oval e caixa baixa)
- **Aconteceu:** no Fluxograma 3 do deck de cashback, o subtítulo "sem saber da campanha" vazava pela curva da oval, e num nó de 124px de altura com título em 2 linhas a tag encostava no topo e o subtítulo saía por baixo.
- **Regra:** altura do nó >= 18 (tag) + 10 + 38 × linhas do título + 26 (subtítulo) + 2 × 12 de folga. Em oval, o subtítulo fica perto da curva: no máximo ~60% da largura da parte reta + raio; encurte o texto antes de alargar a forma.
- **Verificar:** `apthtmlQA.textInShapes('.fc-svg g.pop')` → `[]` (testa os 4 cantos de cada texto contra retângulo, oval e losango).

---

## B. Layout e tipografia (palco 1920×1080)

### B1. Número desalinhado em card estreito
- **Regra:** cards com largura < 360px no bento: conteúdo centralizado (`align-items/justify-content: center; text-align: center`). Número principal nunca ocupa > 80% da largura do card.

### B2. Número estourando o card (ex.: "4.000" a 232px)
- **Regra:** dimensione números display pela largura: `font-size ≤ (largura_card − 2·padding) / (nº de caracteres × 0,62)` para Clash Display. `qa_browser.js` acusa filho maior que o pai (overflow horizontal).

### B3. Título quebrando em 4 a 5 linhas / encostando no conteúdo
- **Regra:** título de slide com no máximo 2 linhas (3 só em coluna estreita, 700px ou menos). Se passar, reduza a fonte do título daquele slide ou use `white-space: nowrap` com fonte menor. Nunca deixe o título empurrar ou tocar o bloco de baixo.
- **Verificar:** `apthtmlQA.run()` lista headings com mais de N linhas e blocos absolutos que se sobrepõem.

### B4. Blocos absolutos se sobrepondo (números x botões no CTA)
- **Regra:** todo filho direto posicionado no slide tem caixa própria; nenhum par pode se interceptar (exceto fundo/decoração com `pointer-events: none`). `qa_browser.js` checa.

### B5. Colisão de nome de classe (`.num` do rodapé = `.num` dos números grandes; `.track` do confronto = `.track` do compliance)
- **Aconteceu 2x:** a segunda vez, a trilha do slide de confronto herdou `position:absolute; top:356px` do `.track` do compliance e os blocos caíram para fora do painel.
- **Regra:** todo componente novo usa prefixo próprio (`.duel-track`, `.duel-axis`). Nunca crie classe genérica curta (`track`, `axis`, `num`, `k`, `v`, `l`, `row`) sem prefixo.
- **Verificar:** `qa_static.py` acusa `[B5]` quando a mesma classe simples é definida como regra solta em 2+ lugares (ignora @media, SVG de logo e o framework do palco).

### B6. Espaço morto em slide (pilares pequenos, vão entre blocos)
- **Regra:** se sobrar > 180px vertical vazio entre o último bloco e o rodapé, aumente escala do conteúdo (statement, texto de apoio) ou redistribua. Texto de apoio mínimo 18px no palco.

### B7. Painel passando do rodapé (content-box)
- **Aconteceu:** no deck Maestro, painéis com `height: 100%` dentro do corpo do slide terminavam 68px abaixo do previsto, por cima do rodapé.
- **Por quê:** sem `box-sizing: border-box`, `height: 100%` soma o padding (34px em cima e embaixo). O B4 não pega: o painel não é filho direto do slide.
- **Regra:** `*, *::before, *::after { box-sizing: border-box; }` no `templates/stage.css` (já está).
- **Verificar:** `qa_browser.js` checa B8 (qualquer bloco passando do topo do rodapé) e B9 (conteúdo maior que a caixa na vertical, com 12px de folga para descendente de letra).

### B8. O QA automático passou e o slide estava quebrado
- **Aconteceu:** `qa_static.py` e `apthtmlQA.run()` deram OK com painel sobre o rodapé, árvore em fonte mono e rótulo cruzado por linha. Só a revisão das capturas achou.
- **Regra:** revisar TODAS as capturas do fim (e as do meio nos slides com diagrama) antes de entregar, mesmo com QA verde. Cada erro achado no olho vira checagem no QA quando for mecânico (B8, B9 e D4 nasceram assim).

---

## C. Imagens e animação de objetos

### C1. Imagem animada "saindo" do próprio círculo/brilho
- **Aconteceu:** só a `<img>` da moeda flutuava; o brilho (pseudo-elemento do pai) ficava parado.
- **Regra:** objeto + seu brilho/sombra/anel ficam num wrapper único; a translação (float) anima o wrapper; rotação/escala anima só o objeto dentro, em torno do próprio centro. Nunca anime um elemento separado de sua moldura.
- **Verificar:** centro do objeto == centro da moldura em 2 frames diferentes (JS `getBoundingClientRect`).

### C2. JPG com fundo preto quadrado sobre fundo com brilho
- **Regra:** objeto recortável (moeda, produto, mascote) vira asset com alfa no build: detectar borda (limiar de luminância), máscara com supersampling, exportar WebP com alfa (`alpha_circle_webp()` em `templates/build.py`, chamada pelo `parts.py`). Nada de `clip-path` chutado.

### C3. Slide animado aparece COMPLETO ao entrar (spoiler do final)
- **Aconteceu:** ao passar do slide 5 para o 6 (confronto), o slide aparecia já no quadro final (blocos, contadores, frase) e só depois "começava". E a frase-resumo surgia no meio da simulação.
- **Por quê:** (1) o "zerar tudo" estava dentro da timeline, que tem `delay`; durante o atraso aparece o HTML estático, que é o quadro final (bom para PDF/sem JS, ruim na entrada). (2) A frase tinha `data-r`: o reveal padrão do deck a mostrava, sobrescrevendo o estado escondido do hook (dois donos).
- **Regra:** todo hook aplica o estado inicial de forma SÍNCRONA ao entrar (`reset()` chamado antes de criar a timeline) e de novo a cada repetição. Elemento animado pelo hook não leva `data-r` (um só dono). O HTML continua com o quadro final para impressão/reduced-motion.
- **Verificar:** entrar no slide pela seta a partir do anterior e medir no 1º quadro (`requestAnimationFrame`) e a 0,6 s: tudo vazio. `qa_static.py` acusa `[C3]` quando um elemento que o hook anima também tem `data-r`.

---

## D. Marca

### D1. Cores fora da paleta (tons "clareados" para contraste)
- **Regra:** só HEX do Manual da Marca (`../wibx-brand/references/manual.md`: primárias, estendidas, complementares) e `rgba()` delas. Se faltar contraste, use a variação (L)/(D) oficial, nunca invente tom. `qa_static.py` acusa HEX fora da paleta.

### D2. Travessões (em dash e en dash)
- **Regra:** zero `—` e `–` no texto visível (regra do usuário + taste skill). Números com hífen: `100-300`. `qa_static.py` acusa.

### D3. Divergências do material do cliente
- **Regra:** quando o arquivo oficial diverge do manual (ex.: SVG `#00ff70` x manual `#22ff7b`) ou o conteúdo é inconsistente (ex.: "D+30" x "30 minutos"), aplique o manual e **pergunte** no fim da entrega. Nunca corrija conteúdo factual em silêncio.

### D4. Texto fora da família do manual (pre, code, kbd)
- **Aconteceu:** no deck Maestro, uma árvore de pastas em `<pre>` e identificadores em `<code>` saíram em monospace do navegador. O manual tem família única (Clash Display).
- **Regra:** o `templates/deck.src.html` fixa `pre, code, kbd, samp` em Clash Display. Alinhamento em colunas se faz com grid, não com espaços dentro de `<pre>`.
- **Verificar:** `qa_browser.js` checa D4: todo elemento com texto próprio precisa ter Clash Display no `font-family` computado.

### D5. Comparativo com concorrente: usuário rejeitou barras, quer confronto visual
- **Aconteceu:** primeira versão do Nossa rede × Ethereum foi um gráfico de barras agrupadas; o usuário não gostou: queria "de um lado a Ethereum, do outro a Nossa rede", com logos, e uma forma visual de explicar a eficiência.
- **Regra:** para "nós × concorrente", use o padrão **Confronto** (`templates/duel-slide.html` + `duel.css` + `duel-hook.js`): dois painéis lado a lado com logo de cada um, o mesmo recorte de tempo simulado, os eventos surgindo no instante real (blocos, lotes, pedidos) e contadores ao vivo, e uma frase-resumo com o multiplicador. Barras só como apoio, nunca como peça principal. Logo do concorrente: Simple Icons monocromático (a cor oficial dele fica fora da paleta).
- **Honestidade:** média real × capacidade declarada deve estar escrito na nota de rodapé do slide, junto com a velocidade da simulação.

### D6. Arte do cliente com fundo chapado cria "emenda" de cor no slide
- **Aconteceu:** o padrão de círculos da marca veio com fundo `#c0f533`; o slide usa `#ccf234`. Aparecia uma linha vertical separando os dois limes.
- **Regra:** padrão/textura/grafismo recortado da arte do cliente entra SEM fundo: converter o fundo em alfa (alfa = escuridão do pixel em relação à cor de fundo) e deixar o slide pintar a cor oficial. Vale para qualquer PNG/JPG com fundo sólido que encosta em outra área de cor.
- **Verificar:** ler o pixel do canto do asset no navegador (canvas `getImageData`): alfa 0.

### D7. Comparativo com concorrente (ex.: Nossa rede × Ethereum)
- **Aconteceu:** o pedido era mostrar a Ethereum como "infinitamente" menor; o deck original ainda dizia "13 s" por bloco (desde 2022 são 12 s).
- **Regra:** pesquise os números atuais do concorrente com fonte e data (WebSearch/WebFetch em fonte primária: Etherscan, Chainspect, docs oficiais) antes de desenhar. Compare média real com média real e deixe claro quando é teto/recorde. Nunca use "infinitamente"; mostre o multiplicador calculado e onde a vantagem é esmagadora (ex.: finalidade 12m48s × 7 s ≈ 110x). Avise o usuário quando a premissa dele estiver exagerada, antes de montar.
- **Visual:** métricas com unidades diferentes = uma linha por métrica, cada uma com escala própria começando em zero; indique "maior é melhor"/"menor é melhor"; linha de fontes no slide. Para a peça principal do comparativo, ver D5.

---

## E. Processo e verificação

### E1. Revisar o arquivo errado
- **Aconteceu:** o navegador ficou no `deck.src.html` (com `%%PLACEHOLDERS%%`) em vez do HTML gerado.
- **Regra:** após todo build, abra o HTML **final** (`deck.html`); antes do screenshot, garanta viewport 1920x1080.

### E2. Só olhar o frame final da animação
- **Regra:** para cada slide animado, 2 capturas: no meio (≈1,2 s) e no fim (≈4 s). Erros de coreografia (A2, C1) só aparecem no meio.

### E3. Build nunca reescreve o fonte
- **Regra:** `deck.src.html` e `parts.py` só com Edit/Write. Scripts leem o fonte e geram o HTML final; nunca reescrevem o fonte.

### E4. Numeração manual de páginas quebra ao inserir slides
- **Regra:** o build numera `<span class="pg">` com o índice real do slide (`templates/build.py`); capa sem rodapé não desloca a conta.

### E5. Contador preso em "0" com reduced-motion
- **Aconteceu:** no porte, com `prefers-reduced-motion`, os `[data-count]` do bento ficaram em "0": só o GSAP preenchia o número.
- **Regra:** o texto do `[data-count]` no fonte já é o valor final ("4.000"); o controller anima de 0 só quando há GSAP e, sem ele, escreve o valor final. Print e PDF mostram o número real.
- **Verificar:** screenshot com `--force-prefers-reduced-motion`.

### E6. Screenshot headless no meio da animação
- **Aconteceu:** `--screenshot` do Chrome headless capturou os `[data-r]` ainda transparentes; o tempo virtual não avança a timeline do GSAP.
- **Regra:** quadro final: `--force-prefers-reduced-motion`. Quadro do meio (E2): navegador real (Claude in Chrome) ou `--virtual-time-budget` curto, conferindo à mão.

### E9. QA de navegador sem Claude in Chrome
- **Aconteceu:** no deck Maestro a extensão não estava conectada. `--screenshot` do Chrome headless não roda o `qa_browser.js` nem avança o GSAP (E6).
- **Regra:** `scripts/qa_headless.mjs` roda o mesmo `qa_browser.js` num Chromium local (Chrome, Chromium, Brave ou Edge, ou `CHROME_PATH`) via puppeteer-core, e tira as capturas do meio e do fim em tempo real. Instale o puppeteer-core numa pasta temporária, nunca na skill: `cd "$(mktemp -d)" && npm i puppeteer-core`.
- **Verificar:** sai com código 1 se houver problema, fonte do manual não carregada ou erro de console (favicon ignorado).

### E7. Viewport de celular em headless
- **Aconteceu:** `--window-size=390,...` parecia cortar o palco; o headless impõe largura mínima de 500px e o screenshot recorta em 390.
- **Regra:** teste de celular em headless com largura ≥ 500, ou em navegador real. O palco escala por `min(innerWidth/1920, innerHeight/1080)`.

### E8. Telas de sistema dentro do celular usam a fonte do celular
- **Regra (usuário):** push notification, tela de bloqueio, SMS/WhatsApp, e-mail, barra de status e telas internas de app de terceiros (app do parceiro) NÃO usam a fonte da marca do deck. Usar `--sys: -apple-system, BlinkMacSystemFont, 'SF Pro Text', <Roboto embutida>, sans-serif` (iPhone = SF Pro; Android = Roboto). Landing page da marca continua com a fonte da marca.
- Mock de tela de sistema leva `data-qa-ignore` (o D4 do `qa_browser.js` não o checa).

### E10. Padrão em `background-image` SVG sai ampliado no PDF
- **Aconteceu:** anéis concêntricos como data-URI de fundo saíram em escala 2x no PDF (Quartz), e a cadeira por cima sumiu.
- **Regra:** textura vetorial repetida vai como `<svg>` inline com `<pattern patternUnits="userSpaceOnUse">`, nunca como `background-image` SVG. Silhueta escura sobre fundo escuro só lê se a textura cobre o fundo inteiro (anéis que passam do meio do bloco).

### E11. Objeto 3D (moeda girando) a partir de vídeo do cliente
- **Aconteceu:** usuário rejeitou o giro 2D (rotateY numa imagem chapada) e mandou uma gravação da moeda 3D girando sobre fundo preto.
- **Regra:** extrair quadros (`ffmpeg`), tirar quadros repetidos (gravação de tela a 120 fps tem ~4 cópias por quadro), achar o período de uma volta pela distância de cada quadro a um quadro de referência, recortar a caixa comum, fundo preto vira alfa (alfa = canal máximo, cor = rgb/alfa) e salvar WebP animado (100 quadros, 400px, q60 ≈ 2,4 MB). No build, embutir os BYTES do arquivo com `raw_data_uri` do `templates/build.py` no `parts.py` (nunca reprocessar com PIL: achata a animação). Se o vídeo vier de pasta temporária do macOS (`/var/folders/.../TemporaryItems`), o sistema bloqueia a leitura: pedir para salvar na Mesa ou em Downloads. Não usar boleto branco "de banco" num deck escuro: boleto em estilo da marca (grafite, contorno e código de barras em Wibx Green, carimbo).

### E12. Captura do painel do navegador atrasada / animação congelada
- **Aconteceu:** screenshots do browser pane mostravam o quadro de outro slide ou o 1º quadro da animação (rAF lento no painel).
- **Regra:** para QA visual do deck inteiro, renderizar com Chrome headless no quadro final: `"Google Chrome" --headless=new --force-prefers-reduced-motion --window-size=1920,1080 --virtual-time-budget=4000 --screenshot=sNN.png "file://...html#NN"` e montar folha de contato com PIL (3x3).

### E13. Véu de cor sobre todos os slides no headless/PDF (Melhor Dia 2K27, 05/10/2026)
- **Aconteceu:** folha de contato do Chrome headless saiu com um véu laranja sobre todos os slides e a capa vazia.
- **Por quê:** `stage.css` tinha `transition-duration: 0.2s` em `*` no reduced-motion. Sem `transition-property` declarado, vale `all`: a troca de `opacity/visibility` do slide virava fade, e o `--virtual-time-budget` capturava o meio do fade.
- **Regra:** no reduced-motion, `transition: none !important` (template corrigido). Vale para o export de PDF, que também liga reduced-motion.
- **Verificar:** primeira folha de contato headless com as mesmas cores do navegador.

### E14. Painel do navegador servindo build antigo
- **Regra:** depois de cada build, navegar com `?v=N` novo na URL; `navigate` para a mesma URL pode reaproveitar o cache e o QA mede o HTML velho.

### E15. Hook de guarda bloqueia edição por shell
- **Regra:** arquivos-fonte só com Edit/Write. Scripts Python podem LER e gerar o HTML final (build), nunca reescrever o fonte.

### E16. Tradutor automático do navegador reescreve o deck
- **Aconteceu:** no navegador do usuário, "Nome do Produto" virou "Boleto de devolução", "Landing" virou "Aterrissagem", "Carteira" virou "Portfólio/Coleção"; os textos ficaram mais longos e quebraram o stepper e as tabelas.
- **Regra:** todo deck sai com `<html lang="pt-BR" translate="no" class="notranslate">` + `<meta name="google" content="notranslate">`. Componentes com rótulos curtos em grade usam `minmax(0, 1fr)` e texto que quebra linha (nunca `nowrap`), para aguentar texto maior sem empurrar a grade.
- **Verificar:** trocar os rótulos por versões longas via JS no navegador e medir sobreposição (0).

### E17. PDF com retângulo escuro no Preview do Mac
- **Aconteceu:** o PDF do Chrome (`--print-to-pdf`) abria certo no poppler, mas no Preview do Mac os slides com celular ganhavam um retângulo escuro em volta do aparelho.
- **Por quê:** `backdrop-filter`, `box-shadow` com blur e `filter: drop-shadow` viram grupos de transparência que o Quartz compõe errado.
- **Regra:** no `@media print`, desligar `backdrop-filter`, `filter` de sombra e `box-shadow` com blur (trocar por cor sólida da paleta); `@page { size: 1920px 1080px; margin: 0 }` e `print-color-adjust: exact`. Exportar com `--force-prefers-reduced-motion --virtual-time-budget=15000` e caminho ABSOLUTO em `--print-to-pdf=` (relativo falha em silêncio).
- **Verificar:** renderizar cada página com o motor do Mac (`pdfseparate` + `sips -s format png`) e olhar a folha de contato; ler o pixel do fundo ao lado dos aparelhos.

### E18. Trocar a fonte de um deck pronto (larguras diferentes)
- **Aconteceu:** usuário trocou Bebas Neue/Roboto por LTC Octic Gothic (títulos, ~1,9x mais larga) e Menlo (texto, mono, ~1,3x mais larga) com o deck já diagramado.
- **Regra:** medir a razão de largura com PIL (`getlength` do mesmo texto nas duas fontes) e compensar com `size-adjust` no `@font-face` (Octic 60%, Menlo 80%), sem mexer em cada `font-size`. Depois reduzir `line-height` dos títulos na mesma proporção (o line-height não acompanha o size-adjust; ficou 0.74 nos `.d-*`, 0.88 nos títulos com faixa de destaque).
- **Fonte com métricas verticais exageradas** (Octic tinha ascent 1536/1000): normalizar hhea/typo/win com fontTools para o bbox real dos acentos antes de embutir, senão a centralização vertical de botões/pílulas sai torta.
- **Peso faltando:** se o usuário manda só o Regular, buscar o Bold no sistema (`/System/Library/Fonts/*.ttc`) para os pesos 700/800 em vez de negrito sintético.
- **Verificar:** `apthtmlQA.run()` (estouros e linhas de título) + folha de contato; títulos que quebram em palavra solta: alargar a caixa ou reduzir só aquele título.
- **Desfecho:** o usuário voltou os títulos para Bebas Neue e manteve só a Menlo no texto. Ao reverter uma fonte de título, desfazer junto os ajustes feitos por causa dela (entrelinha, tamanhos por slide), mas manter os que serviram ao texto.
- **Usuário pediu letras maiores** depois do size-adjust 60%: subiu para Octic 70% / Menlo 88% e ajustou largura das colunas slide a slide (o size-adjust não muda ao vivo pela API FontFace; testar via rebuild).

---

## F. Jornada do usuário / fluxo de app

Origem: deck de cashback (cliente B × parceiro, set/2026).

### F1. Jornada "não está tão clara": usuário quer fluxograma + telas com mãozinha
- **Aconteceu:** a jornada virou um diagrama único de 8 caixas com texto miúdo, e os prints vieram em slides de callouts numerados. O usuário achou confuso.
- **Regra:** jornada de app = (1) fluxograma do tipo Flowchart do diagram-design (oval início/fim, retângulo ação, losango decisão, Sim à direita/Não abaixo, legenda), dividido em 2 fluxos se passar de 9 nós; (2) logo depois, UMA tela por slide, na ordem do fluxo, com contorno Wibx Green no elemento clicável + mãozinha animada tocando nele (ripple) + caixa "Toque em X → abre Y" + stepper dos passos. Zona tracejada no fluxograma quando a jornada troca de aplicativo (ex.: app cliente B → app do parceiro).
- **Verificar:** recortar o print com o retângulo/ponto do toque desenhados (PIL) antes de publicar; o dedo precisa cair no botão certo.

### F2. SVG/ícone some dentro de contêiner de tamanho zero
- **Aconteceu:** fluxograma e mãozinha não apareciam: o reset `img, svg { max-width: 100%; max-height: 100% }` do palco zera o SVG quando o pai tem largura ou altura 0 (âncora `.tap` de 0×0, wrapper sem altura).
- **Regra:** elemento absoluto dentro de âncora 0×0 leva `max-width: none; max-height: none`; wrapper de SVG absoluto recebe `position: absolute; inset: 0`.
- **Verificar:** `getBoundingClientRect()` do SVG com altura > 0.

### F3. Grade de logos desalinhada da barra de passos logo abaixo
- **Aconteceu:** as 15 marcas eram UMA imagem de 700px; a 1ª coluna caía sobre o passo 1, mas a última parava antes do passo 9. O usuário pediu que a grade fosse até "Benefícios".
- **Regra:** blocos empilhados na mesma coluna compartilham a mesma grade. Logos de parceiros viram arquivos individuais (fatiar a arte) em CSS grid; centros das colunas calculados sobre os centros dos elementos de referência (ex.: 5 colunas sobre os passos 1, 3, 5, 7, 9). Tamanho: UMA escala única para todas as logos (mantém a proporção da arte original do cliente); quem ocupa a largura é o espaçamento da grade, não o tamanho das logos. Nunca normalizar por área nem aumentar logos para "preencher" (o usuário rejeitou: marcas ficaram desiguais e grandes demais).
- **Verificar:** medir no navegador o centro de cada coluna e de cada bolinha (`getBoundingClientRect`); diferença 0 px.

---

## G. Conteúdo do cliente

### G1. Texto do documento reescrito sem pedido (proposta comercial, 03/10/2026)
- **Aconteceu:** ao transformar a proposta comercial (DOCX) em deck, os textos foram resumidos, títulos/kickers/frases de efeito criados, rótulos de diagrama inventados ("PARTE ENVOLVIDA", "FUNDING NA EMISSÃO") e um número derivado incluído (alíquota efetiva). O usuário: "Você não pode mudar os textos... Está proibido de mudar os textos."
- **Regra:** documento do cliente vira slide com TEXTO LITERAL. Permitido: quebrar linha, dividir uma frase em trechos consecutivos (ex.: itens (i) a (iv), etapas de um fluxo), destacar trecho por estilo (cor, peso, tamanho via `<span>`), usar célula de tabela ou cabeçalho de seção como rótulo, omitir nada sem avisar. Proibido: parafrasear, resumir, criar título, legenda, rótulo ou número que não esteja no documento, mudar caixa por conteúdo (usar o texto como está). Erros do original (ex.: "arquitetura proposta" sem "A") ficam e são apontados no fim.
- **Verificar:** salvar o texto do documento em `<projeto>/source/proposta.txt` (`textutil -convert txt`), copiar `templates/check_verbatim.py` para o projeto e rodar `python3 check_verbatim.py deck.html` depois de cada build: cada bloco de texto visível (p, div, h*, li, `<text>` do SVG) precisa ser substring do documento, ignorando só espaços. Sai com código 1 se houver texto fora. Travessão que vem do próprio documento fica (qa_static acusa D2; documentar).

### G2. Páginas só de texto "sem graça": usar os elementos da própria marca (proposta comercial, 03/10/2026)
- **Aconteceu:** após a regra de texto literal, slides de parágrafo (8.7/8.8 em dois painéis) ficaram planos; o usuário pediu "use os da marca pra deixar essas páginas mais bonitas".
- **Regra:** antes de inventar decoração, procurar no Manual da Marca (`../wibx-brand/references/manual.md`): (1) **ícones oficiais** (o `wibx-brand` hoje só entrega os logos, em `../wibx-brand/assets/manual/`; se o PDF do manual vier, extrair com `pdftocairo -svg -f N -l N`, descartar a malha de construção = traços finos e longos, agrupar por célula, salvar no projeto em `assets/icons/` com nome pelo desenho e galeria `index.html`); (2) **página editorial do manual** (ícone grande no topo, número da seção + título gigante embaixo à esquerda, texto Regular grande à direita, brilho verde forte de canto). Ícones viram `<symbol id="b-nome">` numa chave do `parts.py` (o build injeta) e substituem os Feather genéricos.
- **CSS:** destaque dentro de bloco de texto precisa vencer a regra do parágrafo (`.ed-text p.ed-val`, `.ed-text p.ed-val b`), senão a cor do texto corrido sobrescreve.

### G3. Cliente com deck anterior: a diagramação dele é lei (Melhor Dia 2K27, 05/10/2026)
- **Aconteceu:** com ID book, fontes e fotos em mãos, criei uma linguagem própria (adesivos com sombra sólida, colagem de fotos tortas). O usuário: "Ficou bem ruim, a gente precisa seguir essa diagramação, esse estilo de design" e mandou o PPTX/Keynote das apresentações anteriores.
- **Regra:** antes da Fase 1, PERGUNTE se existe apresentação anterior da marca (PPTX, Keynote, PDF). Se existir, ela vence a direção estética: extraia do PPTX (zip + XML) a geometria de cada forma (`a:off`/`a:ext` em EMU / 12700 = px num slide 1920), fontes, cores, recortes (`srcRect`) e as mídias originais (`ppt/media`, com qual slide usa cada uma), e monte o deck com OS MESMOS componentes e assets. Keynote: só as mídias saem (formato binário); peça o PPTX exportado + PDF para referência visual.
- **Cuidado:** `imageN.png` e `imageN.jpeg` têm o mesmo número no PPTX; salve com nomes distintos ao converter. Asset repetido em vários slides vai como regra CSS (um só data-URI), senão o HTML passa de 15 MB.
- **Faixa de título centralizada:** `left:0; right:0; margin:auto; width:fit-content`, e nenhuma regra por slide pode redefinir `left`. Correntes como filhas da faixa (balançam juntas).

---

## H. Deck de cashback (out/2026): o que virou regra

### H1. Números e datas de exemplo andam juntos
- **Aconteceu:** usuário trocou o boleto de R$ 850 para R$ 1.500; o cashback +42,50 (5% de 850) ficou fora da faixa 3% a 10%. Antes, a carteira do protótipo mostrava "Hoje, 22/02/2022" num deck de 2026.
- **Regra:** valores, percentuais e datas de exemplo formam um conjunto. Ao mudar um, recalcule os dependentes (cashback = % declarado × valor) e troque em TODAS as telas onde aparece (grep no fonte). Datas de prints e mocks no ano corrente. Pergunte o percentual padrão se não estiver dado; sugira o meio da faixa.

### H2. Trocar texto dentro de um print (sem refazer a tela)
- **Regra:** medir a caixa do texto antigo (pixels claros na linha), cobrir com a cor do fundo do print (amostrada), reescrever com a fonte do sistema do celular (SF Pro: `/System/Library/Fonts/SFNS.ttf`, `set_variation_by_name('Semibold'|'Regular')`), calibrando o tamanho pela largura do texto original; alinhar pelo topo dos dígitos e pelo lado certo (esquerda no cabeçalho, direita na coluna de valores). Guardar o original em `assets/src/`.
- Mock de tela de sistema leva `data-qa-ignore` (o D4 do `qa_browser.js` não o checa).

### H4. Coerência visual do objeto 3D
- **Aconteceu:** moeda extraída do vídeo saiu meio transparente (o corpo escuro virou alfa junto com o fundo preto); depois o usuário pediu "só a moeda, rodando, sem opacidade" e tirou a base wireframe.
- **Regra:** objeto convexo = envoltório convexo sólido (alfa 1) + brilho com alfa só fora da borda (`video_to_webp.py` faz). Objeto 3D sozinho, sem base nem camadas translúcidas atrás.

### H5. Boleto/documento "de banco" num deck escuro
- **Regra:** nada de cartão branco genérico. Documento na linguagem da marca: superfície grafite, contorno e código de barras na cor de destaque, logo do parceiro, valor em fonte display, carimbo circular. Seta de fluxo com `data-packet` até o objeto.

### H6. Erro vermelho no visualizador de arquivos do app
- **Aconteceu:** `history.replaceState` dá SecurityError no iframe sandbox (about:srcdoc) do painel de arquivos.
- **Regra:** `templates/controller.js` já envolve em try/catch (o deck segue sem o #número). Nada a fazer por deck.

### H7. QA com falso alarme de decoração proposital
- **Regra:** `data-qa-ignore` no elemento (logo que sangra, holofote, padrão fora do palco, SVG de fluxo em tela cheia). `.tap`, `.tap-hand` e `.grain` já são ignorados. Meta: `apthtmlQA.run()` → `[]` sem exceções lembradas de cabeça.

### H8. Deck "travando" com muitas animações
- **Aconteceu:** com ícones, setas, moeda e globos animados, o deck ficou pesado: 56 animações rodando ao mesmo tempo (slides ocultos com `visibility:hidden` continuam animando) e um grão de tela cheia com `mix-blend-mode: overlay` (redesenha a tela inteira a cada quadro).
- **Regra:** `templates/stage.css` pausa tudo fora do `.slide.active`; laços em JS (`requestAnimationFrame`) pulam elementos fora do slide ativo; grão sem `mix-blend-mode` (opacity baixa + camada própria); evitar `backdrop-filter` em elementos animados.
- **Verificar:** `document.getAnimations().filter(a => a.playState === 'running').length` só deve contar as do slide atual.

### H9. Objeto 3D do vídeo com "mordida" ou "calombo" no giro
- **Aconteceu:** moeda escura girando: a borda quase preta ficava transparente em alguns quadros (limiar alto), e reflexos soltos do aro faziam um calombo sólido na lateral (envoltório convexo liga tudo). "Preencher a forma real" também falha: partes em preto absoluto viram buracos.
- **Regra:** `video_to_webp.py`: limiar baixo (`--thresh 4`, fundo preto puro); maior região conectada (descarta reflexos soltos); envoltório convexo UNIDO a uma elipse ajustada por RANSAC no contorno externo (repõe trechos do aro renderizados em preto puro, iguais ao fundo). NÃO intersectar com elipse: a espessura da moeda de lado fica fora dela e vira faixa translúcida. Qualidade: `--size 640 --q 80` (~2,1 MB).
- **Aconteceu 2x:** a primeira correção (envoltório ∩ elipse) pareceu certa na folha de contato mas o usuário gravou a tela e a falha seguia. Conferir também a MÁSCARA de alfa com o contorno desenhado sobre o brilho ampliado (x10), não só a imagem final.
- **Verificar:** folha de contato com TODOS os quadros sobre fundo claro (ex.: Wibx Green): mordida e calombo só aparecem assim.

### H10. Objeto 3D: fonte certa = arquivo 3D (.blend), não vídeo nem quadros soltos
- **Aconteceu:** três rodadas tentando recortar a moeda de uma gravação de vídeo (mordida, calombo, borda em preto puro); depois 11 quadros PNG/PSD (giro "aos saltos", e misturar quadros fez fantasma). O usuário tinha o .blend: render direto resolveu tudo de primeira.
- **Regra:** ao precisar de objeto 3D animado, PERGUNTE primeiro pelo arquivo 3D (.blend, .c4d exportado, .glb). Ordem de preferência: `scripts/blender_to_webp.py` (.blend, render com film_transparent, ~5 s/quadro EEVEE, 100 quadros a 640px ≈ 2,9 MB) > `scripts/frames_to_webp.py` (quadros com alfa; intermediários por deformação de largura, nunca mistura) > `scripts/video_to_webp.py` (último recurso).
- Blender: `scripts/setup_3d.sh --install blend` (cask do Homebrew; cria o wrapper `blender` no PATH). Blender instalado pelo `.dmg` não entra no PATH: o `blender_to_webp.py` acha o `/Applications/Blender.app` assim mesmo. O arquivo pode exigir versão nova; cabeçalho `BLENDER17-01` = 5.x. Copie o .blend para o projeto (caminhos do WhatsApp são temporários). Texto gravado na moeda pode mudar entre versões do arquivo do cliente: avise.
