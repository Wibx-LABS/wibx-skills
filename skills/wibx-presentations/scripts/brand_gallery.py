#!/usr/bin/env python3
"""Gera a galeria completa do diagram-design (61 modelos) na marca do cliente.

Uso:
    python3 brand_gallery.py <saida>          # ex.: <projeto>/diagramas

Lê:   gallery/original/          (cópia da galeria oficial, MIT, ver gallery/LICENSE)
      assets/diagram-map.json    (tokens padrão -> paleta do Manual da Marca, fontes)
Grava: <saida>/                  (mesmos nomes de arquivo + index.html navegável)
Nunca grave dentro da pasta da skill: o empacotamento leva tudo o que estiver nela.

O recolor é determinístico: os exemplos usam os tokens do skin padrão (dark: #2d3142/#f5f5f5/#f08a59,
light: #f5f5f5/#2d3142/#eb6c36); cada variante usa seu mapa (arquivos *-dark.html -> "dark").
Relata HEX que sobraram sem mapeamento para você completar o diagram-map.json.
"""
import collections
import json
import re
import sys
from pathlib import Path

SKILL = Path(__file__).resolve().parent.parent
SRC = SKILL / "gallery" / "original"


def recolor(html: str, cmap: dict) -> str:
    hexmap = {k.lower(): v for k, v in cmap["hex"].items()}
    html = re.sub(r"#[0-9a-fA-F]{6}\b", lambda m: hexmap.get(m.group(0).lower(), m.group(0)), html)
    for src, dst in cmap["rgb"].items():
        pat = r"rgba?\(\s*" + r"\s*,\s*".join(src.split(",")) + r"\s*([,)])"
        html = re.sub(pat, lambda m, d=dst: f"rgba({d}{m.group(1)}" if m.group(1) == "," else f"rgb({d})", html)
    return html


def refont(html: str, fonts: dict) -> str:
    sans = fonts["sans"].split(",")[0].strip()
    serif = fonts["serif"].split(",")[0].strip()
    html = re.sub(r"'Geist'(?! Mono)", sans, html)
    html = re.sub(r'"Geist"(?! Mono)', sans.replace("'", '"'), html)
    html = html.replace("'Instrument Serif'", serif).replace('"Instrument Serif"', serif.replace("'", '"'))
    link = f'<link rel="stylesheet" href="{fonts["css_url"]}">'
    extra = f"text[font-family*=\"{sans.strip(chr(39))}\"]{{letter-spacing:{fonts.get('letter_spacing_svg', '0')}}}"
    return html.replace("</head>", f"{link}\n<style>{extra}</style>\n</head>", 1)


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    cfg = json.loads((SKILL / "assets" / "diagram-map.json").read_text())
    out = Path(sys.argv[1]).resolve()
    if SKILL in out.parents or out == SKILL:
        sys.exit("saída dentro da pasta da skill: escolha outro diretório")
    out.mkdir(parents=True, exist_ok=True)
    leftovers = collections.Counter()
    known = {k.lower() for mode in ("dark", "light") for k in cfg[mode]["hex"]} | {v.lower() for mode in ("dark", "light") for v in cfg[mode]["hex"].values()}
    n = 0
    for f in sorted(SRC.glob("*.html")):
        html = f.read_text()
        mode = "dark" if f.stem.endswith("-dark") else "light"
        html = refont(recolor(html, cfg[mode]), cfg["fonts"])
        if f.name == "index.html":
            html = html.replace("Diagram Design · Gallery", "Diagram Design · Galeria WIBX")
        for h in re.findall(r"#[0-9a-fA-F]{6}\b", re.sub(r"data:[^\"')]+", "", html)):
            if h.lower() not in known:
                leftovers[h.lower()] += 1
        (out / f.name).write_text(html)
        n += 1
    print(f"{n} arquivos -> {out}")
    if leftovers:
        print("HEX sem mapeamento (acrescente ao diagram-map.json se forem do skin):")
        for h, c in leftovers.most_common(20):
            print(f"  {h}  {c}x")
    return 0


if __name__ == "__main__":
    sys.exit(main())
