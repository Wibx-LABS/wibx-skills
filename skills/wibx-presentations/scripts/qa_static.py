#!/usr/bin/env python3
"""QA estático do deck final (arquivo único).

Uso:
    python3 qa_static.py deck.html [--no-palette]

Checa (ver references/licoes.md):
  D2  travessões (— e –) no texto visível
  E*  placeholders %%X%% que sobraram do build
  A5  ids duplicados
  D1  HEX fora da paleta do Manual da Marca (wibx-brand/references/manual.md)
  A4  contrato de acessibilidade dos SVGs de diagrama (role=img)
Sai com código 1 se houver falha.
"""
import argparse
import collections
import re
import sys
from pathlib import Path


def visible_text(html: str) -> str:
    html = re.sub(r"<(style|script)\b.*?</\1>", " ", html, flags=re.S | re.I)
    html = re.sub(r"<!--.*?-->", " ", html, flags=re.S)
    html = re.sub(r"<title\b.*?</title>", " ", html, flags=re.S)  # <title> de SVG é texto real também
    return re.sub(r"<[^>]+>", " ", html)


MANUAL = Path(__file__).resolve().parents[2] / "wibx-brand" / "references" / "manual.md"


def brand_palette() -> set[str]:
    p = MANUAL
    if not p.exists():
        sys.exit(f"Manual da marca não encontrado: {p} (a skill wibx-brand precisa estar instalada ao lado)")
    hexes = {h.lower() for h in re.findall(r"#[0-9a-fA-F]{6}\b", p.read_text())}
    return hexes | {"#000000", "#ffffff"}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("html")
    ap.add_argument("--no-palette", action="store_true")
    a = ap.parse_args()
    src = Path(a.html).read_text()
    fails: list[str] = []

    text = visible_text(src)
    for m in re.finditer(r"[—–]", text):
        ctx = text[max(0, m.start() - 30): m.end() + 30].replace("\n", " ")
        fails.append(f"[D2] travessão no texto: ...{ctx.strip()}...")

    for ph in sorted(set(re.findall(r"%%[A-Z0-9_]+%%", src))):
        fails.append(f"[E] placeholder não substituído: {ph}")

    ids = re.findall(r'\sid="([^"]+)"', src)
    for k, v in collections.Counter(ids).items():
        if v > 1:
            fails.append(f"[A5] id duplicado ({v}x): {k}")

    if not a.no_palette:
        pal = brand_palette()
        no_data = re.sub(r"data:[^\"')]+", "", src)
        used = collections.Counter(h.lower() for h in re.findall(r"#[0-9a-fA-F]{6}\b", no_data))
        for h, n in used.items():
            if h not in pal:
                fails.append(f"[D1] cor fora da paleta Wibx: {h} ({n}x)")

    for m in re.finditer(r"<svg\b[^>]*role=\"img\"[^>]*>(.*?)</svg>", src, flags=re.S):
        tag = src[m.start(): src.index(">", m.start()) + 1]
        body = m.group(1).lstrip()
        lab = re.search(r'aria-labelledby="(\S+) (\S+)"', tag)
        if not lab:
            fails.append(f"[A4] SVG sem aria-labelledby title+desc: {tag[:80]}")
            continue
        t, d = lab.groups()
        if not body.startswith(f'<title id="{t}"'):
            fails.append(f"[A4] <title id={t}> não é o primeiro filho")
        if f'<desc id="{d}">' not in body:
            fails.append(f"[A4] <desc id={d}> ausente")
        if t in ("title", "desc") or d in ("title", "desc"):
            fails.append(f"[A4] ids de title/desc sem prefixo: {t}, {d}")

    # A7: pacotes de dados. Legado (translateX / class="packet") é proibido; caminho parcial também.
    if re.search(r'class="packet"|@keyframes packet|translateX\(var\(--d', src):
        fails.append("[A7] pacote legado (class=\"packet\"/translateX): use data-packet no conector")
    for n_svg, m in enumerate(re.finditer(r"<svg\b.*?</svg>", src, flags=re.S), 1):
        conns = re.findall(r"<(?:path|line|polyline)\b[^>]*\bclass=\"[^\"]*\bdraw\b[^\"]*\"[^>]*>", m.group(0))
        by_stroke: dict[str, list[bool]] = collections.defaultdict(list)
        for c in conns:
            st = re.search(r'stroke="([^"]+)"', c)
            by_stroke[st.group(1) if st else "?"].append("data-packet" in c)
        for stroke, flags in by_stroke.items():
            if any(flags) and not all(flags):
                title = re.search(r"<title[^>]*>(.*?)</title>", m.group(0), re.S)
                fails.append(f"[A7] caminho com pacote parcial ({sum(flags)}/{len(flags)} conectores stroke={stroke}) no SVG \"{title.group(1).strip() if title else n_svg}\"")

    n_slides = len(re.findall(r'class="slide[\s"]', src))
    if fails:
        print(f"QA estático: {len(fails)} falha(s) em {n_slides} slides")
        for f in fails:
            print("  -", f)
        return 1
    print(f"QA estático: OK ({n_slides} slides)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
