#!/usr/bin/env python3
"""Confere se TODO texto visível dos slides é cópia literal do documento original.

Regra do usuário: proibido mudar os textos. Cada bloco de texto (p, div, h1-h3, li,
<text> do SVG...) precisa existir, caractere por caractere, em source/proposta.txt.
Espaços e quebras de linha são ignorados na comparação (só a diagramação muda).
Ignora: <style>, <script>, <title>/<desc> de acessibilidade, aria-hidden, número de página.
Uso: python3 check_verbatim.py <deck.html>   (lê source/proposta.txt ao lado deste script)
"""
import re
import sys
from html.parser import HTMLParser
from pathlib import Path

if len(sys.argv) < 2:
    print(__doc__)
    sys.exit(2)
ROOT = Path(__file__).parent
DOC = re.sub(r"\s+", "", (ROOT / "source/proposta.txt").read_text().replace(" ", " "))
INLINE = {"span", "b", "i", "em", "strong", "tspan", "br", "a", "sup", "sub"}
VOID = {"br", "img", "meta", "link", "input", "hr", "use", "rect", "circle", "line", "path",
        "polygon", "polyline", "ellipse", "stop", "source"}
SKIP_TAGS = {"style", "script", "title", "desc", "defs", "head", "nav", "button"}
SKIP_CLASS = {"pg", "sym", "logo"}


class P(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack = []  # (tag, skip, buf)
        self.depth_slide = 0
        self.bad, self.ok = [], 0

    def handle_starttag(self, tag, attrs):
        if tag in VOID:
            return
        a = dict(attrs)
        cls = set((a.get("class") or "").split())
        parent_skip = self.stack[-1][1] if self.stack else False
        skip = parent_skip or tag in SKIP_TAGS or a.get("aria-hidden") == "true" or bool(cls & SKIP_CLASS)
        if tag == "section" and "slide" in cls:
            self.depth_slide += 1
        self.stack.append((tag, skip, []))

    def handle_endtag(self, tag):
        if tag in VOID or not self.stack:
            return
        while self.stack:
            t, skip, buf = self.stack.pop()
            if t in INLINE and self.stack:
                self.stack[-1][2].extend(buf)  # texto inline sobe para o bloco pai
            else:
                txt = "".join(buf)
                if txt.strip() and not skip and self.depth_slide:
                    norm = re.sub(r"\s+", "", txt)
                    if norm in DOC:
                        self.ok += 1
                    else:
                        self.bad.append(re.sub(r"\s+", " ", txt).strip())
            if t == "section":
                self.depth_slide = max(0, self.depth_slide - 1)
            if t == tag:
                break

    def handle_data(self, data):
        if self.stack and not self.stack[-1][1]:
            self.stack[-1][2].append(data.replace(" ", " "))


html = Path(sys.argv[1]).read_text()
p = P()
p.feed(html)
if p.bad:
    print(f"TEXTO FORA DO DOCUMENTO ({len(p.bad)}):")
    for b in p.bad:
        print("  ✗", b)
    sys.exit(1)
print(f"Texto literal: OK ({p.ok} blocos conferidos com source/proposta.txt)")
