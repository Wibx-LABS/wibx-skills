#!/usr/bin/env python3
"""Monta o deck final (arquivo único) a partir de <projeto>/deck.src.html.

Uso:
    python3 build.py <projeto> [saida.html]      # saída padrão: <projeto>/deck.html

Substitui no fonte:
  %%STAGE_CSS%%       templates/stage.css (palco 1920x1080, print, reduced-motion)
  %%CONTROLLER_JS%%   templates/controller.js (navegação, GSAP, modo edição)
  %%LOGO%%            logo oficial "wibx COMPANY" (wibx-brand/assets/manual/logo-light.svg),
                      cores trocadas para as do Manual da Marca (#22ff7b / #070707)
  %%SYMBOL%%          mesmo SVG recortado só no símbolo (viewBox 0 0 221.49 221.49)
  %%<NOME>%%          qualquer chave de PARTS em <projeto>/parts.py (opcional), p.ex. SVG gerado
                      por diagrams.py ou imagem com alfa via alpha_circle_webp()
Numera <span class="pg">NN</span> com o índice real do slide (lições E4) e falha se sobrar placeholder.
Fontes vêm da CDN da Fontshare (link no deck.src.html); nada de woff2 embutido.
"""
import base64
import importlib.util
import re
import sys
from pathlib import Path

TEMPLATES = Path(__file__).resolve().parent
SKILL = TEMPLATES.parent
LOGO_DIR = SKILL.parent / "wibx-brand" / "assets" / "manual"


def logo_svg(viewbox: str | None = None) -> str:
    svg = (LOGO_DIR / "logo-light.svg").read_text()
    svg = re.sub(r"<\?xml[^>]*\?>\s*", "", svg)
    svg = re.sub(r'\s(id|data-name)="[^"]*"', "", svg)  # evita IDs duplicados no HTML
    svg = svg.replace("#00ff70", "#22ff7b").replace("#141414", "#070707")
    if viewbox:
        svg = re.sub(r'viewBox="[^"]*"', f'viewBox="{viewbox}"', svg, count=1)
    return svg.replace("<svg ", '<svg aria-hidden="true" ', 1)


def alpha_circle_webp(path: Path, threshold: int = 14) -> str:
    """Objeto circular recortável (moeda, selo) em JPG com fundo preto -> WebP com alfa, base64.
    Detecta a borda por luminância e aplica máscara circular com supersampling (lições C2). Requer Pillow."""
    import io

    from PIL import Image, ImageDraw

    im = Image.open(path).convert("RGB")
    px = im.convert("L").load()
    w, h = im.size
    xs = [x for x in range(w) if any(px[x, y] > threshold for y in range(0, h, 2))]
    ys = [y for y in range(h) if any(px[x, y] > threshold for x in range(0, w, 2))]
    cx, cy = (xs[0] + xs[-1]) / 2, (ys[0] + ys[-1]) / 2
    r = ((xs[-1] - xs[0]) + (ys[-1] - ys[0])) / 4 - 1
    s = 4
    mask = Image.new("L", (w * s, h * s), 0)
    ImageDraw.Draw(mask).ellipse([(cx - r) * s, (cy - r) * s, (cx + r) * s, (cy + r) * s], fill=255)
    im.putalpha(mask.resize((w, h), Image.LANCZOS))
    buf = io.BytesIO()
    im.save(buf, "WEBP", quality=86, method=6)
    return base64.b64encode(buf.getvalue()).decode()


def project_parts(root: Path) -> dict:
    f = root / "parts.py"
    if not f.exists():
        return {}
    sys.path[:0] = [str(TEMPLATES), str(root)]  # parts.py pode importar diagrams / build
    spec = importlib.util.spec_from_file_location("parts", f)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.PARTS


def main() -> int:
    if len(sys.argv) not in (2, 3):
        print(__doc__)
        return 2
    root = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[2]) if len(sys.argv) == 3 else root / "deck.html"
    html = (root / "deck.src.html").read_text()
    parts = {
        "STAGE_CSS": (TEMPLATES / "stage.css").read_text(),
        "CONTROLLER_JS": (TEMPLATES / "controller.js").read_text(),
        "LOGO": logo_svg(),
        "SYMBOL": logo_svg("0 0 221.49 221.49"),
        **project_parts(root),
    }
    for k, v in parts.items():
        html = html.replace(f"%%{k}%%", v)

    # <span class="pg"> recebe o número real do slide em que está (capa sem rodapé não desloca a conta)
    chunks = re.split(r'(?=<section class="slide[\s"])', html)
    html = chunks[0] + "".join(
        re.sub(r'<span class="pg">\d+</span>', f'<span class="pg">{n:02d}</span>', c) for n, c in enumerate(chunks[1:], 1)
    )

    left = set(re.findall(r"%%[A-Z_0-9]+%%", html))
    if left:
        print(f"placeholders sem valor: {sorted(left)}")
        return 1
    out.write_text(html)
    print(f"{out}: {out.stat().st_size / 1024:.0f} KB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
