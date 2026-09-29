/* APTHTML QA de navegador. Cole o conteúdo inteiro no javascript_tool (browser pane),
   com o deck FINAL aberto e viewport 1920x1080. Depois:
     apthtmlQA.run()                       -> lista de problemas por slide ("[]" = ok)
     apthtmlQA.labelsInCircles(sel, circles, labels, gap)
       sel: seletor do <svg>; circles: {k:[cx,cy,r]}; labels: [[texto, k_do_próprio]]
   Regras em references/licoes.md (B2, B3, B4, B8, B9, D4, A1).
   Sem Claude in Chrome: scripts/qa_headless.mjs roda este mesmo arquivo num Chromium local (lições E9). */
window.apthtmlQA = (() => {
  const W = 1920, H = 1080;
  const BRAND_FONT = 'Clash Display'; // família única do Manual da Marca Wibx (D4)
  const rel = (r, sr, k) => ({ l: (r.left - sr.left) / k, t: (r.top - sr.top) / k, r: (r.right - sr.left) / k, b: (r.bottom - sr.top) / k });
  const inter = (a, b) => Math.max(0, Math.min(a.r, b.r) - Math.max(a.l, b.l)) * Math.max(0, Math.min(a.b, b.b) - Math.max(a.t, b.t));

  function checkSlide(s, n) {
    const out = [];
    const sr = s.getBoundingClientRect(), k = sr.width / W;
    const name = el => (el.className && el.className.baseVal !== undefined ? el.className.baseVal : el.className) || el.tagName.toLowerCase();

    // B*: fora do palco
    s.querySelectorAll('*').forEach(el => {
      if (el.closest('svg') && el.tagName !== 'svg') return;
      const r = el.getBoundingClientRect(); if (!r.width || !r.height) return;
      const q = rel(r, sr, k);
      if (q.r > W + 1 || q.b > H + 1 || q.l < -1 || q.t < -1) out.push(`${n}: fora do palco .${name(el)} (${Math.round(q.r)}x${Math.round(q.b)})`);
    });
    // B2: texto maior que a caixa (overflow horizontal)
    s.querySelectorAll('div,p,h1,h2,h3,span').forEach(el => {
      if (el.closest('svg')) return;
      if (el.scrollWidth > el.clientWidth + 2 && getComputedStyle(el).display !== 'inline' && el.clientWidth > 0)
        out.push(`${n}: texto estoura a caixa .${name(el)} (${el.scrollWidth}>${el.clientWidth})`);
    });
    // B3: títulos com linhas demais
    s.querySelectorAll('h1,h2,.h1,.h2,.display,.statement').forEach(el => {
      const lh = parseFloat(getComputedStyle(el).lineHeight) || parseFloat(getComputedStyle(el).fontSize);
      const lines = Math.round(el.getBoundingClientRect().height / k / lh);
      // .statement = frase manifesto (até 4 linhas); título em coluna estreita: 3; título largo: 2
      const max = el.classList.contains('statement') ? 4 : el.getBoundingClientRect().width / k <= 720 ? 3 : 2;
      if (lines > max) out.push(`${n}: título com ${lines} linhas (máx ${max}): "${el.textContent.trim().slice(0, 40)}"`);
    });
    // B4: blocos posicionados se sobrepondo (filhos diretos do slide + filhos de .head/.copy-col)
    const blocks = [...s.children].filter(el => {
      const cs = getComputedStyle(el);
      return cs.position === 'absolute' && cs.pointerEvents !== 'none' && el.getBoundingClientRect().width && !el.classList.contains('connectors');
    });
    for (let i = 0; i < blocks.length; i++) for (let j = i + 1; j < blocks.length; j++) {
      const a = rel(blocks[i].getBoundingClientRect(), sr, k), b = rel(blocks[j].getBoundingClientRect(), sr, k);
      if (inter(a, b) > 16) out.push(`${n}: sobreposição .${name(blocks[i])} x .${name(blocks[j])}`);
    }
    // Diagrama invadindo rodapé
    const foot = s.querySelector('.foot');
    if (foot) s.querySelectorAll('.dg').forEach(d => {
      if (d.getBoundingClientRect().bottom > foot.getBoundingClientRect().top + 2) out.push(`${n}: diagrama sobre o rodapé`);
    });
    // B8: qualquer bloco (painel, card, tabela) passando do topo do rodapé. Só o mais externo é reportado.
    // Pega o caso que o B4 não vê: filho de .body com height:100% + padding em content-box (lições B7).
    if (foot) {
      const fy = rel(foot.getBoundingClientRect(), sr, k).t;
      const hit = [];
      s.querySelectorAll('*').forEach(el => {
        if (el === foot || foot.contains(el) || el.contains(foot) || (el.closest('svg') && el.tagName !== 'svg')) return;
        const cs = getComputedStyle(el);
        if (cs.display === 'inline' || cs.pointerEvents === 'none') return;
        const r = el.getBoundingClientRect(); if (!r.height) return;
        if (rel(r, sr, k).b > fy - 4 && !hit.some(h => h.contains(el))) {
          hit.push(el); out.push(`${n}: .${name(el)} passa do rodapé (termina em ${Math.round(rel(r, sr, k).b)}, rodapé em ${Math.round(fy)})`);
        }
      });
    }
    // B9: conteúdo maior que a caixa na vertical (texto que vaza por baixo do painel).
    // Folga de 12px: descendente de letra (ç, g, q) passa alguns px da caixa de linha e não é layout quebrado.
    s.querySelectorAll('div,section > *').forEach(el => {
      if (el.closest('svg') || el.classList.contains('slide')) return;
      if (el.clientHeight > 0 && el.scrollHeight > el.clientHeight + 12) out.push(`${n}: .${name(el)} estoura na vertical (${el.scrollHeight}>${el.clientHeight})`);
    });
    // D4: texto fora da família do manual (pre/code/kbd herdam monospace do navegador)
    const bad = new Set();
    s.querySelectorAll('*').forEach(el => {
      if (el.closest('svg') && el.tagName !== 'text' && el.tagName !== 'tspan') return;
      const own = [...el.childNodes].some(c => c.nodeType === 3 && c.textContent.trim());
      if (own && !getComputedStyle(el).fontFamily.includes(BRAND_FONT)) bad.add(`${el.tagName.toLowerCase()} (${getComputedStyle(el).fontFamily.slice(0, 40)})`);
    });
    bad.forEach(b => out.push(`${n}: texto fora da fonte do manual: ${b}`));
    return out;
  }

  function run() {
    const slides = [...document.querySelectorAll('.slide')];
    const cur = slides.findIndex(s => s.classList.contains('active'));
    const out = [];
    slides.forEach((s, i) => {
      const was = s.classList.contains('visible');
      s.classList.add('visible');
      out.push(...checkSlide(s, String(i + 1).padStart(2, '0')));
      if (!was && i !== cur) s.classList.remove('visible');
    });
    return out;
  }

  // A1: cantos do bbox de cada rótulo dentro do próprio círculo e fora dos outros, com folga "gap"
  function labelsInCircles(sel, circles, labels, gap = 16) {
    const svg = document.querySelector(sel), res = [];
    labels.forEach(([txt, own]) => {
      const el = [...svg.querySelectorAll('text')].find(e => e.textContent.trim() === txt);
      if (!el) return res.push(`${txt}: não encontrado`);
      const b = el.getBBox();
      const pts = [[b.x, b.y], [b.x + b.width, b.y], [b.x, b.y + b.height], [b.x + b.width, b.y + b.height]];
      let worst = Infinity;
      pts.forEach(([x, y]) => Object.entries(circles).forEach(([key, [cx, cy, r]]) => {
        const d = Math.hypot(x - cx, y - cy);
        worst = Math.min(worst, key === own ? r - d : d - r);
      }));
      res.push(`${txt}: folga ${Math.round(worst)}px ${worst >= gap ? 'OK' : 'FALHA'}`);
    });
    return res;
  }

  return { run, labelsInCircles, checkSlide };
})();
'apthtmlQA pronto: apthtmlQA.run()';
