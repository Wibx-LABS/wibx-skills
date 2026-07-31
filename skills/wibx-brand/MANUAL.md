# Manual: Wibx Brand Skill

---

#### 🇺🇸 English
**What it does:**
This skill is the one place Wibx's visual identity lives — the Admin Dashboard theme colors (neon green `#00ff70` on deep black), the Red Hat Display type scale, radii and elevation rules, and the official logo SVG. Other skills and artifacts reference it instead of re-typing hex values. If you are about to hardcode a Wibx hex, pull it from here instead.

**Key Features:**
- **Seven Core Tokens:** Background `#0c0c0c`, surface `#141414`, primary `#00ff70`, text `#ebf7ee`, muted `#ababab`, borders `#2e2e2e`, destructive `#f06a6f`. Full palette, type scale and spacing in `references/tokens.md`.
- **Official Logo:** `assets/wibx-logo.svg` — green icon, white wordmark, meant to be embedded inline and scaled with `clamp()`. No extra styling needed on dark backgrounds.
- **Deterministic Ramp Generator:** `scripts/color_ramp.py` builds tints and shades that preserve hue and anchor step 500 to the source color, instead of eyeballed values. Pure python3 stdlib, nothing to install.
- **Contrast Is Reported, Not Assumed:** Every generated step reports WCAG contrast against the Wibx background and text tokens, targeting AA ≥ 4.5 for body and ≥ 3.0 for large text and UI.
- **Three Output Formats:** Human-readable table, CSS custom properties (`--wibx-green-50` … `-950`), or JSON.
- **Built to Be Referenced:** `wibx-presentations` and any UI/design skill should read from here and embed the logo asset rather than duplicating values that then drift.

**Usage:**
Triggers on any Wibx branding work, or on mentions of brand colors/tokens/palette, "Wibx green", `#00ff70`, the logo, or a request for an accessible ramp. Ramp: `python scripts/color_ramp.py --color "#00ff70" [--name green --css | --json]`.

---

#### 🇧🇷 Português
**O que faz:**
Esta skill é o único lugar onde a identidade visual da Wibx mora — as cores do tema do Admin Dashboard (verde neon `#00ff70` sobre preto profundo), a escala tipográfica Red Hat Display, as regras de raio e elevação, e o SVG oficial do logo. Outras skills e artefatos referenciam ela em vez de redigitar hex. Se você está prestes a hardcodar um hex da Wibx, puxe daqui.

**Principais Recursos:**
- **Sete Tokens Centrais:** Fundo `#0c0c0c`, superfície `#141414`, primária `#00ff70`, texto `#ebf7ee`, apagado `#ababab`, bordas `#2e2e2e`, destrutiva `#f06a6f`. Paleta completa, escala tipográfica e espaçamento em `references/tokens.md`.
- **Logo Oficial:** `assets/wibx-logo.svg` — ícone verde, wordmark branco, feito para ser embutido inline e escalado com `clamp()`. Não precisa de estilo extra sobre fundo escuro.
- **Gerador de Ramp Determinístico:** `scripts/color_ramp.py` monta tints e shades que preservam a matiz e ancoram o passo 500 na cor de origem, em vez de valores no olhômetro. Puro python3 stdlib, nada para instalar.
- **Contraste Reportado, Não Presumido:** Todo passo gerado reporta o contraste WCAG contra os tokens de fundo e texto da Wibx, mirando AA ≥ 4.5 para corpo e ≥ 3.0 para texto grande e UI.
- **Três Formatos de Saída:** Tabela legível, custom properties CSS (`--wibx-green-50` … `-950`), ou JSON.
- **Feita para Ser Referenciada:** `wibx-presentations` e qualquer skill de UI/design devem ler daqui e embutir o asset do logo em vez de duplicar valores que depois divergem.

**Uso:**
Dispara em qualquer trabalho de branding Wibx, ou em menções a cores/tokens/paleta da marca, "verde Wibx", `#00ff70`, o logo, ou pedido de ramp acessível. Ramp: `python scripts/color_ramp.py --color "#00ff70" [--name green --css | --json]`.
