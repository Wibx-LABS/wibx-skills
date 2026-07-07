# Wibx Brand Tokens — Canonical Reference

Single source of truth for Wibx's **Admin Dashboard Theme**. Any skill applying
Wibx branding pulls from here instead of hardcoding values.

## Color Palette

| Token | Hex | Role |
|-------|-----|------|
| Background | `#0c0c0c` | Deep black — app/page/deck background |
| Surface / Cards | `#141414` | Elevated dark gray — panels, cards, modals |
| Primary Interactive | `#00ff70` | Neon green ("Wibx green") — CTAs, active/focus, data highlights |
| Text Primary | `#ebf7ee` | Off-white with green tint — body text |
| Muted Text | `#ababab` | Secondary / caption text |
| Borders / Secondary | `#2e2e2e` | Dividers, 1px panel borders |
| Destructive / Error | `#f06a6f` | Errors, destructive actions |

## Typography

- **Font family**: `Red Hat Display`, `Helvetica Neue`, `Arial`, sans-serif
- **Character**: clean, geometric, modern-technical
- **Headers**: bold, high-impact; size with `clamp()` (e.g. `clamp(24px, 5vw, 44px)`)
- **Body**: readable at all sizes; fluid scaling with `clamp()`

## Shape & Elevation

- **Border radius**: `10px` default UI elements; `999px` pill buttons
- **Elevation**: soft drop shadow + 1px semi-transparent white border (glass panel)
- **Borders**: `#2e2e2e` for hard dividers; translucent white for glass edges

## Usage Rules (Dark-First)

1. **Darkness = premium** — deep blacks/grays are the default canvas.
2. **Selective saturation** — grayscale structure; neon green *only* for CTAs,
   active/focus states, data highlights, and deliberate emphasis. Do not flood.
3. **Contrast** — verify green/text on surface tokens with `scripts/color_ramp.py`
   (targets: WCAG AA ≥ 4.5 for body text, ≥ 3.0 for large text/UI).

## Logo

Inline SVG at `assets/wibx-logo.svg` — green icon mark (`#00ff70`) + white wordmark
(`#ffffff`), `viewBox="0 0 222 64.69"`. Scale with `height: clamp(60px, 10vw, 120px)`.
Inherits the dark background; no extra styling required.
