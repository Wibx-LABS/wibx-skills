#!/usr/bin/env python3
"""QA estático do deck final (arquivo único).

Uso:
    python3 qa_static.py deck.html [--no-palette]
    python3 qa_static.py --selftest

Checa (ver references/licoes.md):
  D2  travessões (— e –) no texto visível
  E*  placeholders %%X%% que sobraram do build
  A5  ids duplicados
  D1  HEX fora da paleta do Manual da Marca (wibx-brand/references/manual.md)
  A4  contrato de acessibilidade dos SVGs de diagrama (role=img)
  B5  colisão de classe CSS (mesma classe como regra solta em 2+ lugares)
  C3  elemento controlado por hook de animação que também tem data-r
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


def strip_at_blocks(css: str) -> str:
    """Remove blocos @media/@keyframes/@font-face/@supports inteiros (com chaves aninhadas)."""
    out, i = [], 0
    while True:
        m = re.search(r"@(media|keyframes|font-face|supports)\b[^{]*\{", css[i:])
        if not m:
            out.append(css[i:])
            return "".join(out)
        out.append(css[i:i + m.start()])
        j, depth = i + m.end(), 1
        while j < len(css) and depth:
            depth += {"{": 1, "}": -1}.get(css[j], 0)
            j += 1
        i = j


MANUAL = Path(__file__).resolve().parents[2] / "wibx-brand" / "references" / "manual.md"


def brand_palette() -> set[str]:
    p = MANUAL
    if not p.exists():
        sys.exit(f"Manual da marca não encontrado: {p} (a skill wibx-brand precisa estar instalada ao lado)")
    hexes = {h.lower() for h in re.findall(r"#[0-9a-fA-F]{6}\b", p.read_text())}
    return hexes | {"#000000", "#ffffff"}


def check(src: str, palette: bool) -> list[str]:
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

    if palette:
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

    # B5: colisão de classe CSS (a mesma classe simples definida como regra solta em 2+ lugares).
    page = re.sub(r"<svg\b.*?</svg>", "", src, flags=re.S)  # <style> dentro de SVG (logos) é escopo do SVG
    css = "\n".join(re.findall(r"<style[^>]*>(.*?)</style>", page, flags=re.S))
    css = strip_at_blocks(css)  # @media/@keyframes/@font-face redefinem de propósito
    framework = {"slide", "deck-stage", "deck-viewport", "deck-controls"}  # viewport-base + extensões intencionais
    solo = collections.Counter(re.findall(r"(?:^|\})\s*\.([a-zA-Z][\w-]*)\s*\{", css, flags=re.M))
    for cls, n in solo.items():
        if n > 1 and cls not in framework:
            fails.append(f"[B5] classe .{cls} definida {n}x como regra solta: colisão entre componentes; prefixe (ex.: .{cls} -> .componente-{cls})")

    # C3: elemento controlado por hook não pode ter data-r (dois donos: o reveal padrão o mostra antes da hora)
    for hm in re.finditer(r"deckHooks\.(\w+)\s*=\s*\(.*?\n\};", src, flags=re.S):
        name, body = hm.group(1), hm.group(0)
        # dono = elemento guardado em variável E usado como alvo de animação (g/tl .set/.to/.fromTo)
        var_cls = dict(re.findall(r"const (\w+) = slide\.querySelector\('\.([\w-]+)'\)", body))
        targets = set(re.findall(r"\b(?:g|tl)\.(?:set|to|fromTo)\((\w+)\s*,", body))
        classes = {var_cls[v] for v in targets if v in var_cls}
        sec = re.search(rf'<section\b[^>]*data-hook="{name}".*?</section>', src, flags=re.S)
        if not sec:
            continue
        for tag in re.findall(r"<[a-z]+\b[^>]*\bdata-r\b[^>]*>", sec.group(0)):
            cls = re.search(r'class="([^"]+)"', tag)
            owned = classes & set(cls.group(1).split()) if cls else set()
            if owned:
                fails.append(f"[C3] .{sorted(owned)[0]} é controlado pelo hook \"{name}\" e também tem data-r: remova o data-r")

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

    return fails


def selftest() -> int:
    def page(css: str = "", body: str = "", js: str = "") -> str:
        return f"<style>{css}</style>{body}<script>{js}</script>"

    hook = "window.deckHooks.h = (slide, g) => {\n const el = slide.querySelector('.x');\n g.set(el, {});\n};"
    cases = [
        ("B5 duplicada", page(".a{x:1} .a{x:2}"), "[B5] classe .a", True),
        ("B5 em @media", page(".a{} @media print{.a{}}"), "[B5]", False),
        ("B5 framework", page(".slide{} .slide{}"), "[B5]", False),
        ("C3 hook+data-r", page(body='<section data-hook="h"><div class="x" data-r></div></section>', js=hook), "[C3] .x", True),
    ]
    bad = 0
    for name, html, needle, want in cases:
        got = any(needle in f for f in check(html, False))
        if got != want:
            bad += 1
            print(f"FAIL {name}: esperado {'falha' if want else 'sem falha'} com {needle!r}")
    print("selftest: OK" if not bad else f"selftest: {bad} caso(s) falharam")
    return 1 if bad else 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("html", nargs="?")
    ap.add_argument("--no-palette", action="store_true")
    ap.add_argument("--selftest", action="store_true")
    a = ap.parse_args()
    if a.selftest:
        return selftest()
    if not a.html:
        ap.error("html é obrigatório (ou use --selftest)")
    src = Path(a.html).read_text()
    fails = check(src, not a.no_palette)
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
