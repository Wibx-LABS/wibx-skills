# Direção visual (condensado de frontend-design, high-end-visual-design e design-taste-frontend)

Destilado do pacote apthtml (2026-09-24) para o palco 1920×1080 no Manual da Marca Wibx.
Hierarquia em conflito: **Manual da Marca > estrutura do deck (esta skill) > estas regras de gosto > animação.**
Ex.: o manual pede "01." gigante na abertura de seção; a regra anti-numeração do taste não vale ali.

## 1. Design read + dials (declare em uma linha antes de gerar)

`Design read: <público>, <modo>, <tese visual em 6 palavras> · VARIANCE v · MOTION m · DENSITY d`

| Deck | VARIANCE | MOTION | DENSITY |
|---|---|---|---|
| Padrão corporativo premium (palestra, pitch) | 6 | 6 | 3 |
| Leitura (enviado por e-mail, muito texto) | 5 | 4 | 5 |
| Executivo / board | 5 | 4 | 3 |
| Técnico / engenharia (diagramas densos) | 5 | 6 | 5 |

- **VARIANCE** 1-3 simétrico e centrado · 4-7 deslocado (título à esquerda, dado à direita, grids `1.4fr 1fr 1fr`) · 8-10 zonas vazias enormes, assimetria forte.
- **MOTION** ≤ 4: só `[data-r]` e transições CSS · 5-7: timeline GSAP por slide, diagramas que se desenham · 8+: coreografia por passo (use com parcimônia em deck corporativo).
- **DENSITY** 1-3: uma ideia por slide, texto de apoio ≥ 28px · 4-6: bento, tabela curta, texto de apoio ≥ 22px · nunca abaixo de 18px no palco.

## 2. Tese visual

Cada deck tem uma tese específica ao assunto, não "dark premium genérico". Escolha uma
arquetipia e mantenha no deck inteiro:
- **Editorial Split**: tipografia gigante à esquerda, dado/diagrama à direita.
- **Bento assimétrico**: um card herói (gradiente verde do manual) + cards de apoio menores.
- **Statement**: uma frase de 2 a 4 linhas ocupando o palco, com uma palavra em verde.
Varie layout de slide para slide; nunca 3 slides seguidos com a mesma estrutura.

## 3. Acabamento

- Espaço: margens laterais 128px, topo 112px, rodapé em 56px da base. Deixe respirar; se sobrar > 180px morto, aumente escala (lições B6).
- Cards: raio 24 a 32px, sem borda, sem sombra (manual). Profundidade vem de `#141414` sobre `#070707`, não de sombra.
- Verde é destaque, não fundo: 1 a 2 focais por slide. Card herói com o gradiente `#22ff7b 10% → #9fffc6 90%` no máximo 1 por slide.
- Atmosfera: brilho verde difuso de um canto (radial `rgba(14,201,90,.22)` → transparente). Alternar canto entre seções.
- Ícones: outline traço 1.75 a 2px, `stroke-linecap: round`, em contêiner squircle. Nunca emoji, nunca ícone preenchido.
- Curvas: `cubic-bezier(0.32, 0.72, 0, 1)` ou `expo.out` (GSAP). Nunca `linear`/`ease-in-out` em entrada.
- Anime só `transform` e `opacity`. Nada de blur em elemento grande que se move.

## 4. Proibições (AI tells)

- Travessão (— e –) em qualquer texto visível. `qa_static.py` acusa.
- Três cards idênticos lado a lado sem hierarquia. Se forem três, um é herói.
- Números falsos redondos (99,99%, 50%, 1234). Dado real do cliente ou pergunte.
- Nomes genéricos (João Silva, Acme) e verbos de enchimento ("alavancar", "revolucionar", "seamless", "next-gen").
- Eyebrow de versão (BETA, V2.0) e numeração enfeite (`001 · Capacidades`) fora da abertura de seção do manual.
- Screenshot falso de produto feito com `<div>`. Use imagem real ou não mostre.
- Brilho neon em volta de texto, texto em gradiente em título, cursor customizado.
- Inventar tom de cor para contraste: use as variações (L)/(D) oficiais (lições D1).

## 5. Pre-flight (antes de entregar)

- [ ] Design read + dials declarados; tese específica ao assunto.
- [ ] Só HEX do manual, só Clash Display, logo oficial (nunca redesenhado, nunca todo verde).
- [ ] Todo título em até 2 linhas (3 em coluna ≤ 700px).
- [ ] Cada slide com diagrama tem 1 a 2 focais em verde; demais em branco/cinza.
- [ ] Cada animação tem motivo (hierarquia, narrativa, estado); reduced-motion mostra o quadro final completo.
- [ ] Nenhum layout repetido em 3 slides seguidos.
