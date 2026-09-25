"""Geometria paramétrica dos diagramas (diagram-design, type-loop §2).

loop_svg() devolve o miolo <g> do diagrama Loop: estações num anel, arcos
circulares entre estações (sentido horário), raios tracejados até o hub.
Entradas idênticas geram geometria idêntica.

Uso em <projeto>/parts.py (lido pelo build.py):
    from diagrams import loop_svg
    PARTS = {"LOOP_CICLO": loop_svg(hub={"name": "...", "sublabel": "..."},
                                    stations=[{"name": "...", "sublabel": "...", "focal": True}, ...])}
e no deck.src.html: <svg class="dg" ...><defs>marcadores lp-ar, lp-ar-g, lp-ar-s</defs>%%LOOP_CICLO%%</svg>
"""
import math

GREEN = "#22ff7b"
INK = "rgba(244,244,244,0.55)"


def _inside(px, py, r, pad=0.0):
    x, y, w, h = r
    return x - pad <= px <= x + w + pad and y - pad <= py <= y + h + pad


def _ring_exit(C, R, rect, start_deg, step, gap):
    """Anda pelo círculo a partir de start_deg até sair da caixa (+gap)."""
    a = start_deg
    for _ in range(40000):
        a += step
        px = C[0] + R * math.cos(math.radians(a))
        py = C[1] + R * math.sin(math.radians(a))
        if not _inside(px, py, rect, gap):
            return a, px, py
    raise RuntimeError("arco sem saída")


def _ray_exit(C, ang, rect, from_inside, gap):
    """Distância ao longo do raio em que o ponto sai (ou entra) na caixa."""
    ux, uy = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    t = 0.0
    while t < 2000:
        t += 0.25
        px, py = C[0] + ux * t, C[1] + uy * t
        ins = _inside(px, py, rect, gap)
        if from_inside and not ins:
            return px, py
        if not from_inside and ins:
            return C[0] + ux * (t - 0.25), C[1] + uy * (t - 0.25)
    raise RuntimeError("raio sem interseção")


def loop_svg(stations, hub, C=(500, 350), R=292, sw=224, sh=84, hw=272, hh=128):
    n = len(stations)
    assert 5 <= n <= 8, "Loop: 5 a 8 estações"
    thetas = [-90 + k * 360 / n for k in range(n)]
    rects = []
    for th in thetas:
        cx = C[0] + R * math.cos(math.radians(th))
        cy = C[1] + R * math.sin(math.radians(th))
        rects.append((round((cx - sw / 2) / 4) * 4, round((cy - sh / 2) / 4) * 4, sw, sh))
    hub_rect = (C[0] - hw / 2, C[1] - hh / 2, hw, hh)
    out = []

    # 1. Arcos do anel (desenhados antes das caixas)
    arcs = []
    for k in range(n):
        j = (k + 1) % n
        a0, x0, y0 = _ring_exit(C, R, rects[k], thetas[k], 0.02, 6)
        end_deg = thetas[j] if thetas[j] > thetas[k] else thetas[j] + 360
        a1, x1, y1 = _ring_exit(C, R, rects[j], end_deg, -0.02, 10)
        large = 1 if (a1 - a0) % 360 > 180 else 0
        d = f"M {x0:.3f} {y0:.3f} A {R} {R} 0 {large} 1 {x1:.3f} {y1:.3f}"
        arcs.append(d)
        focal_edge = stations[j].get("focal") or stations[k].get("focal")
        col, mk = (GREEN, "lp-ar-g") if focal_edge else (INK, "lp-ar")
        out.append(f'<path class="draw" data-seq="{k + 1}" d="{d}" fill="none" stroke="{col}" stroke-width="1.6" marker-end="url(#{mk})"/>')
    # Fluxo contínuo sobre o anel (loop; some com reduced-motion)
    for k, d in enumerate(arcs):
        out.append(f'<path class="flow fade" data-seq="{n + 2}" d="{d}" fill="none" stroke="rgba(159,255,198,0.85)" stroke-width="3" stroke-dasharray="2 12" stroke-linecap="round"/>')

    # 2. Raios tracejados estação -> hub (escrita no estado compartilhado)
    for k, st in enumerate(stations):
        sx, sy = _ray_exit(C, thetas[k], hub_rect, True, 8)
        ex, ey = _ray_exit(C, thetas[k], rects[k], False, 8)
        out.append(f'<line class="fade" data-seq="{n + 1}" x1="{ex:.2f}" y1="{ey:.2f}" x2="{sx:.2f}" y2="{sy:.2f}" stroke="rgba(244,244,244,0.40)" stroke-width="1.3" stroke-dasharray="5 5" marker-end="url(#lp-ar-s)"/>')
        if st.get("spoke_label"):
            my = (ey + sy) / 2
            out.append(f'<text class="fade t-arrow" data-seq="{n + 1}" x="{C[0] + 18}" y="{my + 5:.1f}">{st["spoke_label"]}</text>')

    # 3. Hub
    hx, hy = hub_rect[0], hub_rect[1]
    out.append(f'<g class="pop" data-seq="0"><rect x="{hx}" y="{hy}" width="{hw}" height="{hh}" rx="14" fill="#f4f4f4"/>'
               f'<text x="{C[0]}" y="{C[1] - 6}" text-anchor="middle" class="t-hub">{hub["name"]}</text>'
               f'<text x="{C[0]}" y="{C[1] + 26}" text-anchor="middle" class="t-hubsub">{hub["sublabel"]}</text></g>')

    # 4. Estações (por cima dos arcos)
    for k, st in enumerate(stations):
        x, y, w, h = rects[k]
        cx = x + w / 2
        if st.get("focal"):
            box = f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="#070707"/><rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="rgba(34,255,123,0.12)" stroke="{GREEN}" stroke-width="1.5"/>'
            name_style = ' style="fill:#22ff7b"'
        else:
            box = f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="#141414" stroke="rgba(255,255,255,0.24)"/>'
            name_style = ""
        out.append(f'<g class="pop" data-seq="{k + 1}">{box}'
                   f'<text x="{cx}" y="{y + 36}" text-anchor="middle" class="t-name"{name_style}>{st["name"]}</text>'
                   f'<text x="{cx}" y="{y + 62}" text-anchor="middle" class="t-sub-m">{st["sublabel"]}</text></g>')
    return "\n        ".join(out)

