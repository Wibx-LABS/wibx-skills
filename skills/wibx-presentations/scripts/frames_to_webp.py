#!/usr/bin/env python3
"""Objeto 3D girando a partir de QUADROS-CHAVE com transparência (PNG ou camadas de um PSD) -> WebP animado
em laço, suave. Preferir isto a video_to_webp.py sempre que o cliente tiver os quadros: sem recorte de fundo,
borda perfeita e qualidade do arquivo original. Ver references/licoes.md H10.

uso:
  python3 frames_to_webp.py <pasta_png | arquivo.psd> <saida.webp> [--size 640] [--between 8] [--fps 30] [--q 85]
                            [--order nome1,nome2,...] [--reverse]

- PSD: cada camada visível é um quadro, em ordem de nome (Moeda00, Moeda01...). PNG: ordem alfabética.
- Cada quadro é centralizado num quadro comum (sem "andar" de lado) e reduzido para --size.
- Entre cada par de quadros-chave gera --between intermediários: a largura vai de A para B (giro em torno
  do eixo vertical); cada intermediário usa o quadro-chave mais próximo (sem mistura, que faz fantasma).
  O último quadro emenda no primeiro.
- No build, embutir os BYTES (raw_data_uri de templates/build.py): reprocessar com PIL achata a animação.
"""
import argparse
import glob
import os

import numpy as np
from PIL import Image


def load(src, order):
    if src.lower().endswith((".psd", ".psb")):
        from psd_tools import PSDImage
        psd = PSDImage.open(src)
        layers = {l.name: l for l in psd if l.visible and l.kind == "pixel"}
        names = order or sorted(layers)
        return [(n, layers[n].topil().convert("RGBA")) for n in names]
    fs = sorted(glob.glob(os.path.join(src, "*.png")))
    if order:
        fs = [os.path.join(src, n if n.endswith(".png") else n + ".png") for n in order]
    return [(os.path.basename(f), Image.open(f).convert("RGBA")) for f in fs]


def premul(im):
    a = np.asarray(im).astype(np.float32) / 255.0
    a[..., :3] *= a[..., 3:4]
    return a


def unpremul(a):
    out = a.copy()
    al = out[..., 3:4]
    out[..., :3] = np.where(al > 1e-4, out[..., :3] / np.maximum(al, 1e-4), 0)
    return Image.fromarray((np.clip(out, 0, 1) * 255 + 0.5).astype(np.uint8), "RGBA")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src"); ap.add_argument("out")
    ap.add_argument("--size", type=int, default=640)
    ap.add_argument("--between", type=int, default=8)
    ap.add_argument("--fps", type=int, default=30)
    ap.add_argument("--q", type=int, default=85)
    ap.add_argument("--order", default="")
    ap.add_argument("--reverse", action="store_true")
    a = ap.parse_args()

    keys = load(a.src, [s.strip() for s in a.order.split(",") if s.strip()])
    if a.reverse:
        keys = keys[::-1]
    print("quadros-chave:", [n for n, _ in keys])
    # recorta cada um no próprio conteúdo
    keys = [(n, im.crop(im.getchannel("A").getbbox())) for n, im in keys]
    H = max(im.height for _, im in keys)
    Wmax = max(im.width for _, im in keys)
    side = max(H, Wmax) + 8
    k = a.size / side
    S = a.size

    def scaled(im, w):
        w = max(2, int(round(w * k)))
        h = max(2, int(round(im.height * k)))
        return im.resize((w, h), Image.LANCZOS)

    def place(im):
        c = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        c.alpha_composite(im, ((S - im.width) // 2, (S - im.height) // 2))
        return c

    frames = []
    n = len(keys)
    for i in range(n):
        A = keys[i][1]; B = keys[(i + 1) % n][1]
        for j in range(a.between + 1):
            t = j / (a.between + 1)
            w = A.width + (B.width - A.width) * t        # largura anda linear (giro contínuo)
            # SEM mistura (mistura cria fantasma e transparência): usa o quadro-chave mais próximo,
            # deformado para a largura intermediária; a troca acontece no meio do caminho.
            src = A if t < 0.5 else B
            frames.append(place(scaled(src, w)))
    frames[0].save(a.out, save_all=True, append_images=frames[1:], duration=round(1000 / a.fps), loop=0,
                   quality=a.q, method=6, alpha_quality=90)
    print(f"{a.out}: {os.path.getsize(a.out) // 1024} KB, {len(frames)} quadros {S}px, volta {len(frames) / a.fps:.1f}s")


if __name__ == "__main__":
    main()
