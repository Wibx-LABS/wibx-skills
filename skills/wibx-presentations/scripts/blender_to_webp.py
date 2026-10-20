#!/usr/bin/env python3
"""Objeto 3D animado a partir de um arquivo .blend -> WebP animado em laço, fundo transparente.
MELHOR fonte possível (ordem: .blend > quadros PNG/PSD > vídeo). Ver references/licoes.md H10.

uso:
  python3 blender_to_webp.py <arquivo.blend> <saida.webp> [--size 640] [--step 2] [--fps 30] [--q 82]
                             [--start N] [--end N] [--still FRAME saida_still.png]

- Renderiza a animação que já está na cena (câmera e luzes do artista), com film_transparent, em PNG RGBA,
  no tamanho --size (quadrado). --step 2 = um quadro a cada dois (60 fps da cena -> 30 fps no deck).
- Monta o WebP animado; embutir os BYTES no build (raw_data_uri de templates/build.py).
- --still: renderiza também uma pose parada (para o PDF ou para outros slides).
Requer Blender na mesma versão (ou mais nova) do arquivo: `brew install --cask blender`.
Tempo: EEVEE ~5 s por quadro a 640px num Mac M; 100 quadros ~9 min (rode em segundo plano).
"""
import argparse
import glob
import os
import subprocess
import tempfile

RENDER = r'''
import bpy, sys
a = sys.argv[sys.argv.index("--") + 1:]
out, frames, size = a[0], [int(f) for f in a[1].split(",")], int(a[2])
sc = bpy.context.scene; r = sc.render
r.film_transparent = True
r.resolution_x = r.resolution_y = size; r.resolution_percentage = 100
r.image_settings.file_format = "PNG"; r.image_settings.color_mode = "RGBA"
for f in frames:
    sc.frame_set(f); r.filepath = f"{out}/f_{f:05d}.png"
    bpy.ops.render.render(write_still=True)
    print("RENDER", f, flush=True)
'''

INFO = r'''
import bpy
sc = bpy.context.scene
print("RANGE", sc.frame_start, sc.frame_end, sc.render.fps)
'''


def blender(blend, script, *args):
    with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False) as f:
        f.write(script)
    p = subprocess.run(["blender", "-b", blend, "--python", f.name, "--", *args], capture_output=True, text=True)
    os.unlink(f.name)
    return p.stdout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("blend"); ap.add_argument("out")
    ap.add_argument("--size", type=int, default=640)
    ap.add_argument("--step", type=int, default=2)
    ap.add_argument("--fps", type=int, default=30)
    ap.add_argument("--q", type=int, default=82)
    ap.add_argument("--start", type=int); ap.add_argument("--end", type=int)
    ap.add_argument("--still", nargs=2, metavar=("FRAME", "PNG"))
    ap.add_argument("--frames-dir", help="reaproveita PNGs já renderizados (pula o render)")
    a = ap.parse_args()

    rng = [l.split() for l in blender(a.blend, INFO).splitlines() if l.startswith("RANGE")][0]
    start = a.start or int(rng[1]); end = a.end or int(rng[2])
    frames = list(range(start, end, a.step))          # end exclusivo: o último quadro = primeiro (laço)
    d = a.frames_dir or tempfile.mkdtemp(prefix="blend-")
    if not a.frames_dir:
        print(f"renderizando {len(frames)} quadros ({start}-{end}, passo {a.step}) em {d} ...", flush=True)
        blender(a.blend, RENDER, d, ",".join(map(str, frames)), str(a.size))
    if a.still:
        sd = tempfile.mkdtemp(prefix="still-")
        blender(a.blend, RENDER, sd, a.still[0], str(a.size * 2))
        os.replace(glob.glob(f"{sd}/f_*.png")[0], a.still[1])
        print("pose parada:", a.still[1])

    from PIL import Image
    fs = sorted(glob.glob(f"{d}/f_*.png"))
    ims = [Image.open(f).convert("RGBA") for f in fs]
    ims[0].save(a.out, save_all=True, append_images=ims[1:], duration=round(1000 / a.fps), loop=0,
                quality=a.q, method=6, alpha_quality=90)
    print(f"{a.out}: {os.path.getsize(a.out) // 1024} KB, {len(ims)} quadros {a.size}px, volta {len(ims) / a.fps:.1f}s")


if __name__ == "__main__":
    main()
