#!/usr/bin/env python3
"""Generate an accessible Wibx color ramp from brand hex colors.

Deterministic, pure stdlib (no external deps). Takes one or two brand hex
colors, emits a 50-950 tonal ramp preserving hue, and reports WCAG contrast
of every step against the Wibx background and primary-text tokens.

Usage:
    python color_ramp.py                         # defaults: green #00ff70 on bg #0c0c0c
    python color_ramp.py --color "#00ff70"
    python color_ramp.py --color "#00ff70" --bg "#0c0c0c" --text "#ebf7ee"
    python color_ramp.py --color "#00ff70" --name green --css   # emit CSS custom props
    python color_ramp.py --color "#00ff70" --json                # machine-readable

Output (default): a table of step / hex / contrast-vs-bg / contrast-vs-text / WCAG grade.
"""

import argparse
import colorsys
import json
import sys

# Wibx canonical anchors (source of truth: skills/wibx-brand/references/tokens.md)
DEFAULT_COLOR = "#00ff70"   # Primary Interactive - neon green
DEFAULT_BG = "#0c0c0c"      # Background - deep black
DEFAULT_TEXT = "#ebf7ee"    # Text Primary - off-white with green tint

# Tonal steps -> target lightness (0..1). 500 is anchored to the source color's own L.
STEP_LIGHTNESS = {
    50: 0.96, 100: 0.90, 200: 0.80, 300: 0.70, 400: 0.60,
    500: None,  # anchored to source lightness
    600: 0.44, 700: 0.36, 800: 0.28, 900: 0.20, 950: 0.13,
}


def hex_to_rgb(h):
    h = h.strip().lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    if len(h) != 6:
        raise ValueError(f"invalid hex color: #{h}")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def rgb_to_hex(rgb):
    return "#" + "".join(f"{max(0, min(255, round(c))):02x}" for c in rgb)


def _srgb_channel(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4


def relative_luminance(rgb):
    r, g, b = (_srgb_channel(c) for c in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast_ratio(rgb1, rgb2):
    l1, l2 = relative_luminance(rgb1), relative_luminance(rgb2)
    hi, lo = max(l1, l2), min(l1, l2)
    return (hi + 0.05) / (lo + 0.05)


def wcag_grade(ratio):
    """Grade for normal-size text."""
    if ratio >= 7.0:
        return "AAA"
    if ratio >= 4.5:
        return "AA"
    if ratio >= 3.0:
        return "AA-large"
    return "fail"


def build_ramp(color_hex):
    r, g, b = hex_to_rgb(color_hex)
    h, l_base, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
    ramp = {}
    for step, target_l in STEP_LIGHTNESS.items():
        l = l_base if target_l is None else target_l
        # Ease saturation down at the extremes so tints/shades don't get muddy.
        edge = abs(l - 0.5) * 2  # 0 at mid, 1 at extremes
        s_step = s * (1.0 - 0.25 * edge)
        rr, gg, bb = colorsys.hls_to_rgb(h, l, s_step)
        ramp[step] = rgb_to_hex((rr * 255, gg * 255, bb * 255))
    return ramp


def analyze(ramp, bg_hex, text_hex):
    bg, text = hex_to_rgb(bg_hex), hex_to_rgb(text_hex)
    rows = []
    for step, hx in ramp.items():
        rgb = hex_to_rgb(hx)
        c_bg = contrast_ratio(rgb, bg)
        c_text = contrast_ratio(rgb, text)
        rows.append({
            "step": step,
            "hex": hx,
            "contrast_vs_bg": round(c_bg, 2),
            "grade_vs_bg": wcag_grade(c_bg),
            "contrast_vs_text": round(c_text, 2),
            "grade_vs_text": wcag_grade(c_text),
        })
    return rows


def main(argv=None):
    p = argparse.ArgumentParser(description="Generate an accessible Wibx color ramp.")
    p.add_argument("--color", default=DEFAULT_COLOR, help="source brand hex (default Wibx green)")
    p.add_argument("--bg", default=DEFAULT_BG, help="background hex for contrast checks")
    p.add_argument("--text", default=DEFAULT_TEXT, help="text hex for contrast checks")
    p.add_argument("--name", default="brand", help="token name used in CSS var output")
    p.add_argument("--css", action="store_true", help="emit CSS custom properties")
    p.add_argument("--json", action="store_true", dest="as_json", help="emit JSON")
    args = p.parse_args(argv)

    try:
        ramp = build_ramp(args.color)
        rows = analyze(ramp, args.bg, args.text)
    except ValueError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1

    if args.as_json:
        print(json.dumps({"source": args.color, "ramp": ramp, "analysis": rows}, indent=2))
        return 0

    if args.css:
        print(":root {")
        for step, hx in ramp.items():
            print(f"  --wibx-{args.name}-{step}: {hx};")
        print("}")
        return 0

    print(f"Wibx ramp from {args.color}  (bg {args.bg} / text {args.text})\n")
    print(f"{'step':>5}  {'hex':>8}  {'vs-bg':>6} {'grade':>8}  {'vs-text':>7} {'grade':>8}")
    print("-" * 54)
    for row in rows:
        print(f"{row['step']:>5}  {row['hex']:>8}  "
              f"{row['contrast_vs_bg']:>6} {row['grade_vs_bg']:>8}  "
              f"{row['contrast_vs_text']:>7} {row['grade_vs_text']:>8}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
