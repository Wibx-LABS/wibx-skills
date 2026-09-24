# Wibx: Manual da Marca (decks e peças de marca)

Fonte: WIBX Brand Guide, Pocket Version, © 2024 Wibx Company, 34 págs. Extraído em 2026-09-23.
Escopo: apresentações, peças de marca e material institucional. UI de produto segue o tema
Admin Dashboard em `tokens.md` (decisão de 2026-09-24: deck é peça de marca, não produto).
Escrita da marca em texto corrido: **Wibx** (W maiúsculo, resto minúsculo). No logotipo: "wibx" minúsculo.

## Assets locais

| Asset | Caminho |
|---|---|
| Logo principal, fundo escuro (símbolo verde + texto branco) | `assets/manual/logo-light.svg` |
| Logo principal, fundo claro (símbolo verde + texto preto) | `assets/manual/logo-dark.svg` |
| Mono branco (fundo escuro) | `assets/manual/logo-mono-white.svg` |
| Mono preto (fundo claro) | `assets/manual/logo-mono-black.svg` |
| Fonte Clash Display | CDN Fontshare (os woff2 não são redistribuídos aqui) |

Os 4 SVGs são a assinatura **"wibx COMPANY"** (símbolo + "wibx" + "COMPANY" abaixo), viewBox `0 0 755.07 221.49`. Símbolo isolado: mesmo SVG com `viewBox="0 0 221.49 221.49"` (recorta só o quadrado da esquerda, sem redesenhar).

Atenção: os SVGs oficiais usam verde `#00ff70` e preto `#141414`; o manual define `#22ff7b` e `#070707`. Em HTML, sobrescrever o fill do símbolo para `#22ff7b` para bater com o manual (ou manter o SVG intacto se o cliente preferir o arquivo original; perguntar se em dúvida).

## Cores

### Institucionais (primárias)
| Nome | HEX | Uso |
|---|---|---|
| Wibx Green | `#22ff7b` | Cor principal, destaque sobre fundo escuro |
| Wibx Black | `#070707` | Fundo padrão |
| Wibx White | `#ffffff` | Texto sobre escuro |

Filosofia do manual: "verde vibrante para destacar a comunicação em contraste com o espaço escuro de fundo". Base da marca é **escura**.

### Estendida (apoio, nunca primária)
| Nome | HEX |
|---|---|
| Green (L) | `#9fffc6` |
| Green (D) | `#0ec95a` |
| Black (L) | `#141414` |
| Black (D) | `#000000` |
| White (L) | `#f4f4f4` |
| White (D) | `#cccccc` |

### Complementar (versatilidade: status, categorias, gráficos)
Red `#ed2b2b` · Pink `#ff48be` · Purple `#8e2cff` · Blue `#1346d6` · Light Blue `#19d6e0` · Green `#17c137` · Yellow `#ffb600` · Orange `#ff6d24`

Regra prática para decks: uma cor complementar por categoria, no máximo 2 a 3 por slide; nunca competir com o Wibx Green como destaque principal. Red reservado para erro/alerta ("NÃO" do manual usa Red).

### Gradientes
Sempre cor primária → contraparte estendida, com stops **10% primária / 90% estendida**:
- `linear-gradient(90deg, #22ff7b 10%, #9fffc6 90%)`
- `linear-gradient(90deg, #070707 10%, #141414 90%)`
- `linear-gradient(90deg, #ffffff 10%, #f4f4f4 90%)`

Assinatura visual do manual: fundo Wibx Black com **brilho verde difuso vindo de um canto** (radial, verde Green (D) → transparente), como nas páginas do guia. Usar como atmosfera, não como gradiente de card.

## Tipografia

Família única: **Clash Display** (Indian Type Foundry / Fontshare).

| Papel | Peso | Referência do manual |
|---|---|---|
| Títulos e chamadas | SemiBold (600) | 90pt / 82 entrelinha (line-height ~0.91) |
| Tópico de destaque | Medium (500) | 50pt / 55 (lh 1.1) |
| Texto de apoio grande | Regular (400) | 50pt / 55 |
| Tópico pequeno / eyebrow | Medium (500), TODAS MAIÚSCULAS | 25pt / 30 |
| Chamada / link | Medium (500), sublinhado verde + seta ↗ | 35pt |
| Texto longo | Regular (400) | leveza para leitura |

Proporção título:tópico ≈ 1.8:1. Títulos grandes e fortes, tracking levemente negativo.
Web: Fontshare CDN `https://api.fontshare.com/v2/css?f[]=clash-display@400,500,600,700&display=swap`, com fallback `sans-serif`. Deck offline exige os woff2 locais; confirmar a licença da ITF antes de embutir.

## Logo: regras

- Fundo escuro: texto **Wibx White** + símbolo Green/Black. Fundo claro: texto **Wibx Black** + símbolo Green/Black.
- Sobre Wibx Green: logotipo em Wibx Black com ícone em modo negativo (contorno).
- Monocromático: negativo em fundo claro, branco em fundo escuro.
- Sobre foto: texto branco + gradiente Wibx Black de 40% para 0% de opacidade atrás.
- **Área de segurança**: x = altura do símbolo / 2, em todos os lados.
- **Tamanho mínimo**: logo completo 100px digital (40mm impresso); símbolo sozinho 30px (15mm).
- Símbolo segue as mesmas regras do logo.

### Proibido
- Pintar o logotipo inteiro de Wibx Green.
- Empilhar símbolo sobre o texto.
- Usar o texto "wibx" sem o símbolo.
- Alterar a proporção entre símbolo e texto; distorcer, recolorir, reorganizar.

### Co-branding
- Produto próprio: logo + nome do produto em Clash Display Bold, altura igual à altura-x, cor White (ex.: "wibx SHOPP").
- Parceiro: Wibx sempre à **esquerda**, separado por traço vertical, parceiro à direita.

## Iconografia

Biblioteca própria (1000+ ícones): **traço linear, cantos arredondados, peso de traço uniforme, contêiner quadrado com cantos suaves** (squircle), monocromático branco sobre escuro. Em HTML, emular com ícones outline de traço ~1.75 a 2px, `stroke-linecap: round`, `stroke-linejoin: round`; evitar ícones preenchidos ou emoji.

## Componentes recorrentes do manual
- Cards com raio grande (~24 a 32px em 1920px), sem borda, sem sombra.
- Rodapé de página: símbolo pequeno à esquerda · seção · "Manual da Marca" · copyright · número.
- Seção de abertura: número grande "01." + título gigante SemiBold no canto inferior esquerdo, texto de apoio Regular no quadrante superior direito.
- Rótulo de destaque: barra vertical verde à esquerda + texto verde.

## Tom de voz
O manual (versão pocket) não detalha tom de voz. Inferido dos textos do guia: direto, confiante, frases curtas, português brasileiro, sem jargão desnecessário, foco em benefício ("Potencialize o engajamento e fidelidade..."). Confirmar com o cliente se houver guia verbal completo.
