#!/usr/bin/env python3
"""Objeto 3D girando (ex.: moeda) a partir de um vídeo/gravação de tela sobre fundo preto -> WebP animado
em laço, com fundo transparente e corpo SÓLIDO. Ver references/licoes.md E11.

uso: python3 video_to_webp.py <video.mov> <saida.webp> [--size 400] [--ref 40] [--q 62] [--fps 30] [--hollow]

Passos:
 1. extrai os quadros (ffmpeg) e descarta repetidos (gravação de tela a 120 fps repete cada quadro ~4x);
 2. acha o período de UMA volta: menor distância de um quadro de referência (--ref) a outro quadro adiante;
 3. recorta a caixa comum do objeto em todos os quadros (sem "respirar");
 4. fundo preto -> alfa: fora do objeto alfa = canal máximo (mantém brilho/glow) e cor = rgb/alfa;
    dentro do contorno do objeto (envoltório convexo) alfa = 1, para o corpo escuro NÃO ficar transparente
    (--hollow desliga isso, para objetos não convexos);
 5. salva WebP animado. No build, embutir os BYTES (raw_data_uri de templates/build.py), nunca reprocessar com PIL.
Arquivo do macOS em pasta temporária (/var/folders/.../TemporaryItems) é bloqueado: peça para salvar na
Mesa ou em Downloads. Meta de peso: até ~2 MB (o HTML é arquivo único).
"""
import argparse
import glob
import os
import subprocess
import tempfile

import numpy as np
from PIL import Image, ImageDraw, ImageFilter


def hull(pts):
    pts = sorted(set(map(tuple, pts)))
    if len(pts) < 3:
        return pts
    cr = lambda o, a, b: (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
    lo, up = [], []
    for p in pts:
        while len(lo) >= 2 and cr(lo[-2], lo[-1], p) <= 0:
            lo.pop()
        lo.append(p)
    for p in reversed(pts):
        while len(up) >= 2 and cr(up[-2], up[-1], p) <= 0:
            up.pop()
        up.append(p)
    return lo[:-1] + up[:-1]


def fit_ellipse(x, y):
    """Ajuste direto de elipse (Fitzgibbon): coeficientes a,b,c,d,e,f de ax²+bxy+cy²+dx+ey+f=0."""
    D1 = np.vstack([x * x, x * y, y * y]).T
    D2 = np.vstack([x, y, np.ones_like(x)]).T
    S1, S2, S3 = D1.T @ D1, D1.T @ D2, D2.T @ D2
    T = -np.linalg.solve(S3, S2.T)
    M = S1 + S2 @ T
    M = np.array([M[2] / 2, -M[1], M[0] / 2])
    w, v = np.linalg.eig(M)
    cond = 4 * v[0] * v[2] - v[1] ** 2
    a1 = v[:, np.where(cond > 0)[0][0]].real
    return np.concatenate([a1, T @ a1])


def ellipse_mask(coef, S, grow):
    """Máscara da elipse ajustada, crescida `grow` px (cobre a espessura da moeda vista de lado)."""
    a, b, c, d, e, f = coef
    yy, xx = np.mgrid[0:S, 0:S].astype(float)
    val = a * xx * xx + b * xx * yy + c * yy * yy + d * xx + e * yy + f
    inside = val * np.sign(a) <= 0
    m = Image.fromarray((inside * 255).astype(np.uint8))
    return m.filter(ImageFilter.MaxFilter(grow | 1)) if grow > 1 else m


def largest_component(b):
    """Maior região conectada (4-vizinhança) de uma máscara booleana."""
    H, W = b.shape
    lab = np.zeros((H, W), np.int32)
    best, best_n, n = 0, 0, 0
    for y0, x0 in zip(*np.nonzero(b)):
        if lab[y0, x0]:
            continue
        n += 1
        st = [(y0, x0)]; lab[y0, x0] = n; cnt = 0
        while st:
            y, x = st.pop(); cnt += 1
            for yy, xx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                if 0 <= yy < H and 0 <= xx < W and b[yy, xx] and not lab[yy, xx]:
                    lab[yy, xx] = n; st.append((yy, xx))
        if cnt > best_n:
            best, best_n = n, cnt
    return lab == best


def silhouette(lum, S, thresh):
    """Corpo sólido do objeto girando = envoltório convexo da MAIOR região conectada.
    Moeda (cilindro) vista de qualquer ângulo é convexa, inclusive com a espessura aparecendo; a maior
    região descarta reflexos soltos do aro (que o envoltório ligaria num "calombo"). Não cortar com elipse:
    a espessura fica fora dela e vira faixa translúcida no giro."""
    body = Image.fromarray(((np.array(lum) > thresh) * 255).astype(np.uint8))
    body = body.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(5))   # fecha frestas
    small = body.resize((S // 2, S // 2), Image.NEAREST)
    core = largest_component(np.array(small) > 0)
    core = np.array(Image.fromarray((core * 255).astype(np.uint8)).resize((S, S), Image.NEAREST)) > 0
    core &= np.array(body) > 0
    ys, xs = np.where(core)
    if len(xs) < 50:
        return np.zeros((S, S))
    m = Image.new("L", (S, S), 0)
    ImageDraw.Draw(m).polygon(hull(np.stack([xs, ys], 1)), fill=255)
    sol = np.array(m) > 0
    # Partes do objeto renderizadas em preto puro (iguais ao fundo) somem da máscara e viram "mordida".
    # Repõe pela forma: elipse robusta no contorno externo visível, UNIDA ao envoltório.
    try:
        cx, cy = xs.mean(), ys.mean()
        ang = np.floor((np.arctan2(ys - cy, xs - cx) + np.pi) / (2 * np.pi) * 180).astype(int) % 180
        rad = np.hypot(xs - cx, ys - cy)
        far = np.full(180, -1.0); ex = np.zeros(180); ey = np.zeros(180)
        for i in np.argsort(rad):
            far[ang[i]] = rad[i]; ex[ang[i]] = xs[i]; ey[ang[i]] = ys[i]
        ok = far > 0
        ex, ey, far = ex[ok], ey[ok], far[ok]
        # RANSAC: o aro verdadeiro é o maior conjunto de pontos que cabe numa elipse; pontos do trecho
        # "mordido" (recuados) ficam de fora e não puxam o ajuste.
        rng = np.random.default_rng(0)
        best, best_in = None, -1
        n = len(ex)
        for _ in range(300):
            idx = rng.choice(n, 8, replace=False)
            try:
                cf = fit_ellipse(ex[idx], ey[idx])
            except Exception:
                continue
            A, B, C, D, E, F = cf
            if B * B - 4 * A * C >= 0:          # não é elipse
                continue
            Fv = A * ex * ex + B * ex * ey + C * ey * ey + D * ex + E * ey + F
            gx = 2 * A * ex + B * ey + D; gy = B * ex + 2 * C * ey + E
            d = np.abs(Fv) / np.maximum(np.hypot(gx, gy), 1e-9)      # distância aproximada à borda
            inl = (d < 3.0).sum()
            if inl > best_in:
                best, best_in = cf, inl
        coef = best
        el = np.array(ellipse_mask(coef, S, 0)) > 0
        hull_area = sol.sum()
        if best_in > 0.45 * n and 0.6 * hull_area < el.sum() < 1.35 * hull_area:   # elipse plausível
            sol = sol | el
    except Exception:
        pass
    return np.array(Image.fromarray((sol * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8))) / 255.0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("video"); ap.add_argument("out")
    ap.add_argument("--size", type=int, default=400)
    ap.add_argument("--ref", type=int, default=40, help="quadro único de referência para achar o período")
    ap.add_argument("--q", type=int, default=62)
    ap.add_argument("--fps", type=int, default=30)
    ap.add_argument("--hollow", action="store_true")
    ap.add_argument("--thresh", type=int, default=9, help="brilho mínimo (0-255) que conta como objeto no contorno sólido")
    a = ap.parse_args()

    tmp = tempfile.mkdtemp(prefix="v2w-")
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", a.video, f"{tmp}/f_%05d.png"], check=True)
    fs = sorted(glob.glob(f"{tmp}/f_*.png"))
    small = [np.array(Image.open(f).convert("L").resize((96, 96)), float) for f in fs]
    keep = [0]
    for i in range(1, len(small)):
        if np.abs(small[i] - small[keep[-1]]).mean() > 0.3:
            keep.append(i)
    U = np.array([small[i] for i in keep])
    ref = min(a.ref, len(U) - 20)
    dist = np.abs(U - U[ref]).mean((1, 2))
    cand = [i for i in range(ref + 10, len(U) - 1) if dist[i] <= dist[i - 1] and dist[i] <= dist[i + 1]]
    # primeira volta que fecha bem (não a "melhor", que pode ser 2 ou 3 voltas depois)
    if cand:
        best = min(dist[i] for i in cand)
        end = next(i for i in cand if dist[i] <= best * 1.5 + 0.5)
    else:
        end = len(U)
    loop = [keep[i] for i in range(ref, end)]
    print(f"{len(fs)} quadros, {len(keep)} únicos, volta = {len(loop)} quadros (dist {dist[end] if cand else '-'})")

    # caixa comum
    bb = None
    for i in loop:
        g = np.array(Image.open(fs[i]).convert("RGB")).max(-1)
        ys, xs = np.where(g > 22)
        b = (xs.min(), ys.min(), xs.max(), ys.max())
        bb = b if bb is None else (min(bb[0], b[0]), min(bb[1], b[1]), max(bb[2], b[2]), max(bb[3], b[3]))
    cx, cy = (bb[0] + bb[2]) // 2, (bb[1] + bb[3]) // 2
    half = max(bb[2] - bb[0], bb[3] - bb[1]) // 2 + 6
    S = a.size
    frames = []
    for i in loop:
        im = Image.open(fs[i]).convert("RGB").crop((cx - half, cy - half, cx + half, cy + half)).resize((S, S), Image.LANCZOS)
        px = np.array(im).astype(float)
        k = np.clip(px - 6, 0, None)
        al = np.clip(k.max(-1) / 255 * 1.15, 0, 1)
        rgb_k = np.where(al[..., None] > 0.004, k / np.maximum(al[..., None], 1e-3), 0).clip(0, 255)
        if a.hollow:
            solid = np.zeros_like(al)
        else:
            # contorno pelo brilho suavizado com limiar BAIXO: a borda escura do objeto (quase preta)
            # precisa entrar no corpo sólido, senão vira "mordida" transparente no giro.
            # Pontos brilhantes soltos fora do corpo (reflexos do aro) são removidos por abertura
            # morfológica antes do envoltório, senão viram um "calombo" sólido na lateral.
            # Não usar "preencher a forma real": objetos escuros têm partes em preto absoluto iguais ao
            # fundo e viram buracos. Envoltório puro liga reflexos soltos e faz calombo. Ver silhouette().
            lum = Image.fromarray(px.max(-1).astype(np.uint8)).filter(ImageFilter.GaussianBlur(2))
            solid = silhouette(lum, S, a.thresh)
        alpha = np.maximum(solid, al)
        rgb = px * solid[..., None] + rgb_k * (1 - solid[..., None])
        frames.append(Image.fromarray(np.dstack([rgb.clip(0, 255), alpha * 255]).astype(np.uint8)))
    frames[0].save(a.out, save_all=True, append_images=frames[1:], duration=round(1000 / a.fps), loop=0,
                   quality=a.q, method=6, alpha_quality=70)
    print(f"{a.out}: {os.path.getsize(a.out) // 1024} KB, {len(frames)} quadros {S}px")


if __name__ == "__main__":
    main()
