---
name: wibx-brand
description: Canonical source of Wibx brand tokens, in two scopes. The Admin Dashboard theme for product UI (neon green #00ff70 on deep black, Red Hat Display) and the official Brand Manual for decks and brand pieces (#22ff7b on #070707, Clash Display, logo rules, gradients, complementary palette), plus the official logo SVGs. Use this skill WHENEVER you apply Wibx branding to anything — websites, dashboards, decks, docs, emails, READMEs, components — or when the user mentions "Wibx brand", "brand colors/tokens/palette", "Wibx green", "#00ff70", brand guidelines, the Wibx logo, or asks to generate an accessible color ramp/theme from the brand colors. Other Wibx skills should reference this instead of hardcoding hex values.
compatibility: None (reference tokens + python3 stdlib script)
---

# Wibx Brand

The one place Wibx's visual identity lives. Colors, type, shape, logo — plus a
deterministic accessible-ramp generator. Reference these tokens instead of
re-typing hex values in every skill or artifact.

---

## When to Use This Skill

Trigger whenever you (or another skill) are:
- Applying Wibx look-and-feel to any surface — web UI, dashboard, deck, doc, email
- Asked about Wibx brand colors, tokens, palette, "Wibx green", `#00ff70`, or brand guidelines
- Placing the Wibx logo
- Generating a tonal color ramp or theme from the brand colors, or checking brand contrast for accessibility

If you're about to hardcode a Wibx hex value, stop and pull it from here.

---

## Two Scopes: pick one per surface

| Surface | Scope | Source |
|---|---|---|
| Product UI: web app, dashboard, component, email template | Admin Dashboard theme | `references/tokens.md` (quick reference below) |
| Deck, pitch, keynote, one-pager, institutional piece | Brand Manual | `references/manual.md` + `assets/manual/*.svg` |

Brand Manual core: Wibx Green `#22ff7b`, Wibx Black `#070707`, White `#ffffff`, font
Clash Display (Fontshare CDN), "wibx COMPANY" signature logo. Read `references/manual.md`
in full before producing a brand piece: logo rules, forbidden uses, gradients and the
complementary palette live there. Never mix scopes on one surface.

---

## Core Tokens (Quick Reference)

| Token | Hex |
|-------|-----|
| Background | `#0c0c0c` |
| Surface / Cards | `#141414` |
| Primary Interactive (Wibx green) | `#00ff70` |
| Text Primary | `#ebf7ee` |
| Muted Text | `#ababab` |
| Borders / Secondary | `#2e2e2e` |
| Destructive / Error | `#f06a6f` |

- **Font**: `Red Hat Display`, `Helvetica Neue`, `Arial`, sans-serif
- **Radius**: `10px` UI, `999px` pills
- **Elevation**: soft shadow + 1px translucent white border (glass)

Full palette, type scale, spacing, and dark-first usage rules → `references/tokens.md`.

---

## Logo

Official logo SVG (green icon + white wordmark, `viewBox="0 0 222 64.69"`) lives at
`assets/wibx-logo.svg`. Embed inline; scale with:

```css
.logo { height: clamp(60px, 10vw, 120px); display: block; }
```

Icon mark `#00ff70`, wordmark `#ffffff`. Inherits the dark background — no extra styling.

---

## Generating an Accessible Ramp

For tints/shades or theme scales beyond the seven core tokens, use the deterministic
generator instead of eyeballing values. It preserves hue, anchors step 500 to the
source color, and reports WCAG contrast of every step against the Wibx background and
text tokens.

```bash
# Human-readable table (contrast vs bg + vs text, WCAG grade per step)
python scripts/color_ramp.py --color "#00ff70"

# CSS custom properties (--wibx-green-50 … --wibx-green-950)
python scripts/color_ramp.py --color "#00ff70" --name green --css

# Machine-readable
python scripts/color_ramp.py --color "#00ff70" --json
```

Pure python3 stdlib — no install. Targets: WCAG AA ≥ 4.5 (body text), ≥ 3.0 (large text / UI).

---

## For Other Skills

- **wibx-presentations**: Brand Manual scope (`references/manual.md`, `assets/manual/`).
  Its `qa_static.py` reads the manual's hex values as the allowed palette.
- Any UI/design skill: read core tokens above (or `references/tokens.md`) and embed
  `assets/wibx-logo.svg` rather than duplicating.
- Need a shade not in the seven tokens? Generate it with `scripts/color_ramp.py` so
  it stays on-hue and contrast-checked — don't invent ad-hoc hex values.
