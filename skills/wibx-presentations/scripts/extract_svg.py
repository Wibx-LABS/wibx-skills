#!/usr/bin/env python3
"""Extrai o <svg> principal de um exemplo da galeria e prefixa TODOS os ids.

Uso:
    python3 extract_svg.py <exemplo.html> <prefixo> [--anim]

Ex.: python3 extract_svg.py <projeto>/diagramas/example-sankey-dark.html sk --anim > <projeto>/sk.svg

Por quê: vários diagramas no mesmo deck compartilham ids (#arrow, #dots, #title...). Sem prefixo,
url(#arrow) do slide 8 aponta para o marcador do slide 5 (lições A5).
--anim: marca conectores (path/line com marker-end) como class="draw" e nós (<g> com rect) como
class="pop", com data-seq na ordem do documento, prontos para o controller.js. Ajuste a ordem à mão.
Depois: troque o conteúdo pelos dados reais, adicione class="dg" no <svg> e posicione no slide.
"""
import re
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    html = Path(sys.argv[1]).read_text()
    pre = sys.argv[2]
    anim = "--anim" in sys.argv
    svgs = re.findall(r"<svg\b(?:(?!aria-hidden=\"true\").)*?role=\"img\".*?</svg>", html, flags=re.S)
    if not svgs:
        svgs = sorted(re.findall(r"<svg\b.*?</svg>", html, flags=re.S), key=len)[-1:]
    svg = svgs[0]
    ids = set(re.findall(r'\sid="([^"]+)"', svg))
    for i in sorted(ids, key=len, reverse=True):
        n = f"{pre}-{i}"
        svg = re.sub(rf'\sid="{re.escape(i)}"', f' id="{n}"', svg)
        svg = svg.replace(f"url(#{i})", f"url(#{n})").replace(f'href="#{i}"', f'href="#{n}"')
        svg = re.sub(rf'(aria-labelledby="[^"]*)\b{re.escape(i)}\b', rf"\g<1>{n}", svg)
    if anim:
        seq = 0
        def conn(m):
            nonlocal seq
            seq += 1
            tag = m.group(0)
            return tag if "class=" in tag else tag.replace(m.group(1), f'{m.group(1)} class="draw" data-seq="{seq}"', 1)
        svg = re.sub(r"(<(?:path|line|polyline))\b[^>]*marker-end[^>]*>", conn, svg)
    print(svg)
    return 0


if __name__ == "__main__":
    sys.exit(main())
