# Lições aprendidas (erros reais, corrigidos com o usuário)

Origem: deck Cash Management / WiBX (2026-09-23), via pacote apthtml. Itens E5 a E7 do porte para esta skill (2026-09-24).
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
- **Por quê:** validar o deck inteiro como se fosse um diagrama conta logos, ícones e scripts.
- **Regra:** valide o contrato (role=img, `<title>` primeiro filho, ids prefixados, aria-labelledby title+desc) só nos SVGs de diagrama. `qa_static.py` faz isso.

### A5. Diagramas: remover slide antigo deixou restos
- **Regra:** substitua seções inteiras com um único Edit (texto exato lido com Read); nunca comente blocos com `<!-- -->` (comentários internos quebram). Depois, `qa_static.py` acusa ids duplicados.

### A7. Pacote de dados só em uma das linhas do caminho
- **Aconteceu:** na arquitetura, a bolinha só saía na linha do Débito; Crédito e Ajustes (linhas com cotovelo) ficavam sem.
- **Por quê:** pacotes eram círculos soltos animados com `translateX`, que só anda em linha reta; desenhei só onde a reta coincidia. A bolinha não sabia qual caminho seguir.
- **Regra:** pacote nunca é um elemento avulso. Marque o conector com `data-packet` e o controller gera a bolinha percorrendo o path real (`getPointAtLength`), depois que a linha se desenha. Todos os conectores do mesmo caminho (mesma cor/papel) recebem `data-packet`, inclusive os com cotovelo. Proibido `translateX`/`--d` para mover pacote.
- **Verificar:** `qa_static.py` acusa caminho parcial (um conector com `data-packet` e outro irmão da mesma cor sem) e pacote legado (`class="packet"`, `translateX`). No navegador, amostre `cx/cy` das `.packet-dot` por 3 s: cada uma deve cobrir o path inteiro (passar pelos cotovelos).

### A6. Galeria recolorida: fonte da marca pode ser mais larga que a Geist
- **Regra:** depois de `brand_gallery.py`, sirva a pasta por HTTP (`python3 -m http.server`) e meça em iframes (mesma origem) se cada `<text>` cabe no menor `<rect>` que o contém, após `document.fonts.ready`. Confirme que a fonte da marca carregou (`document.fonts.check`) antes de confiar no resultado. WiBX/Clash Display: 1 estouro em 61 modelos, e ele já existia no original (texto mono).
- **Ao extrair um modelo para o slide:** remova o `<rect>` de fundo de tela cheia do exemplo (o slide já tem fundo e brilho).

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

### B5. Colisão de nome de classe (`.num` do rodapé = `.num` dos números grandes)
- **Regra:** prefixe classes por componente (`.foot .pg`, `.bento .num`). Antes de criar classe genérica curta (`num`, `k`, `v`, `l`), procure se já existe no arquivo.

### B6. Espaço morto em slide (pilares pequenos, vão entre blocos)
- **Regra:** se sobrar > 180px vertical vazio entre o último bloco e o rodapé, aumente escala do conteúdo (statement, texto de apoio) ou redistribua. Texto de apoio mínimo 18px no palco.

---

## C. Imagens e animação de objetos

### C1. Imagem animada "saindo" do próprio círculo/brilho
- **Aconteceu:** só a `<img>` da moeda flutuava; o brilho (pseudo-elemento do pai) ficava parado.
- **Regra:** objeto + seu brilho/sombra/anel ficam num wrapper único; a translação (float) anima o wrapper; rotação/escala anima só o objeto dentro, em torno do próprio centro. Nunca anime um elemento separado de sua moldura.
- **Verificar:** centro do objeto == centro da moldura em 2 frames diferentes (JS `getBoundingClientRect`).

### C2. JPG com fundo preto quadrado sobre fundo com brilho
- **Regra:** objeto recortável (moeda, produto, mascote) vira asset com alfa no build: detectar borda (limiar de luminância), máscara com supersampling, exportar WebP com alfa (`alpha_circle_webp()` em `templates/build.py`, chamada pelo `parts.py`). Nada de `clip-path` chutado.

---

## D. Marca

### D1. Cores fora da paleta (tons "clareados" para contraste)
- **Regra:** só HEX do BRAND.md (primárias, estendidas, complementares) e `rgba()` delas. Se faltar contraste, use a variação (L)/(D) oficial, nunca invente tom. `qa_static.py --brand <slug>` acusa HEX fora da paleta.

### D2. Travessões (em dash e en dash)
- **Regra:** zero `—` e `–` no texto visível (regra do usuário + taste skill). Números com hífen: `100-300`. `qa_static.py` acusa.

### D3. Divergências do material do cliente
- **Regra:** quando o arquivo oficial diverge do manual (ex.: SVG `#00ff70` x manual `#22ff7b`) ou o conteúdo é inconsistente (ex.: "D+30" x "30 minutos"), aplique o manual e **pergunte** no fim da entrega. Nunca corrija conteúdo factual em silêncio.

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

### E7. Viewport de celular em headless
- **Aconteceu:** `--window-size=390,...` parecia cortar o palco; o headless impõe largura mínima de 500px e o screenshot recorta em 390.
- **Regra:** teste de celular em headless com largura ≥ 500, ou em navegador real. O palco escala por `min(innerWidth/1920, innerHeight/1080)`.
