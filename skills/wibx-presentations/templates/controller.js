/* APTHTML controller: palco 16:9, navegação, timeline GSAP por slide, modo edição.
   Origem: deck Cash Management (validado). Requer gsap@3 via CDN antes deste script.
   Convenções: [data-r] reveal de leitura | [data-seq]+.draw/.pop/.fade ordem do diagrama |
   data-step no <section> = ritmo | [data-count] contador | marker-end só aparece quando a linha chega (lições A2). */
/* ===========================================
   CONTROLADOR DO DECK: palco 16:9, navegação, animações por slide
   =========================================== */
class SlidePresentation {
  constructor() {
    this.stage = document.getElementById('deckStage');
    this.slides = [...document.querySelectorAll('.slide')];
    this.current = 0;
    this.tl = null;
    this.reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    this.gsap = window.gsap && !this.reduce ? window.gsap : null;
    this.setupScale();
    this.setupNav();
    const fromHash = parseInt(location.hash.replace('#', ''), 10);
    this.show(Number.isFinite(fromHash) ? fromHash - 1 : 0, true);
  }

  /* Escala o palco 1920x1080 inteiro, sem reflow */
  setupScale() {
    const fit = () => {
      const f = Math.min(innerWidth / 1920, innerHeight / 1080);
      this.stage.style.transform = `translate(${(innerWidth - 1920 * f) / 2}px, ${(innerHeight - 1080 * f) / 2}px) scale(${f})`;
    };
    fit();
    addEventListener('resize', fit);
  }

  setupNav() {
    document.addEventListener('keydown', e => {
      if (e.target.isContentEditable) return;
      if (['ArrowRight', 'PageDown', ' '].includes(e.key)) { e.preventDefault(); this.go(1); }
      if (['ArrowLeft', 'PageUp'].includes(e.key)) { e.preventDefault(); this.go(-1); }
      if (e.key === 'Home') this.show(0);
      if (e.key === 'End') this.show(this.slides.length - 1);
    });
    document.getElementById('nextBtn').onclick = () => this.go(1);
    document.getElementById('prevBtn').onclick = () => this.go(-1);
    let lock = false;
    addEventListener('wheel', e => {
      if (lock || Math.abs(e.deltaY) < 30) return;
      lock = true; this.go(e.deltaY > 0 ? 1 : -1);
      setTimeout(() => { lock = false; }, 700);
    }, { passive: true });
    let tx = null;
    addEventListener('touchstart', e => { tx = e.touches[0].clientX; }, { passive: true });
    addEventListener('touchend', e => {
      if (tx === null) return;
      const dx = tx - e.changedTouches[0].clientX;
      if (Math.abs(dx) > 50) this.go(dx > 0 ? 1 : -1);
      tx = null;
    });
  }

  go(d) { this.show(this.current + d); }

  show(i, first) {
    i = Math.max(0, Math.min(i, this.slides.length - 1));
    if (i === this.current && !first) return;
    this.current = i;
    this.slides.forEach((s, k) => { s.classList.toggle('active', k === i); s.classList.toggle('visible', k === i); });
    const n = String(i + 1).padStart(2, '0');
    document.getElementById('count').textContent = `${n} / ${String(this.slides.length).padStart(2, '0')}`;
    document.getElementById('progress').style.width = `${((i + 1) / this.slides.length) * 100}%`;
    history.replaceState(null, '', `#${i + 1}`);
    this.animate(this.slides[i]);
  }

  /* Uma timeline por slide, recriada na entrada.
     Motivos: [data-r] = hierarquia de leitura; .draw = conexões se formando;
     [data-seq] = ordem do fluxo; [data-count] = magnitude dos números. */
  animate(slide) {
    const g = this.gsap;
    /* Sem GSAP (reduced-motion ou CDN fora): quadro final estático, contadores já no valor real */
    const fmt = v => Math.round(v).toLocaleString('pt-BR');
    if (!g) { slide.querySelectorAll('[data-count]').forEach(el => { el.textContent = fmt(Number(el.dataset.count)); }); return; }
    if (this.tl) this.tl.progress(1).kill();
    const tl = this.tl = g.timeline({ defaults: { ease: 'expo.out', duration: 1.1 } });

    tl.fromTo(slide.querySelectorAll('[data-r]'), { autoAlpha: 0, y: 44 }, { autoAlpha: 1, y: 0, stagger: 0.075 }, 0.05);

    /* Diagramas: [data-seq] define a ordem do fluxo; data-step (no slide) o ritmo.
       .draw = traço se desenha; .pop = nó entra com escala; .fade = só opacidade. */
    const seqEls = [...slide.querySelectorAll('[data-seq]')];
    const base = seqEls.length ? 0.45 : 0;
    const step = Number(slide.dataset.step || 0.32);
    seqEls.forEach(el => {
      const at = base + Number(el.dataset.seq) * step;
      if (el.classList.contains('draw')) {
        const len = el.getTotalLength ? Math.ceil(el.getTotalLength()) + 2 : 100;
        const dur = Number(el.dataset.dur || 0.55);
        tl.fromTo(el, { strokeDasharray: len, strokeDashoffset: len }, { strokeDashoffset: 0, duration: dur, ease: 'power2.inOut', clearProps: 'strokeDasharray,strokeDashoffset' }, at);
        /* Ponta da seta só aparece quando a linha chega ao destino */
        const mk = el.getAttribute('marker-end') || el.dataset.marker;
        if (mk) {
          el.dataset.marker = mk;
          el.removeAttribute('marker-end');
          tl.call(() => el.setAttribute('marker-end', mk), null, at + dur * 0.96);
        }
      } else if (el.classList.contains('pop')) {
        tl.fromTo(el, { autoAlpha: 0, scale: 0.88, transformOrigin: '50% 50%' }, { autoAlpha: 1, scale: 1, duration: 0.8 }, at);
      } else if (el.classList.contains('fade')) {
        tl.fromTo(el, { autoAlpha: 0 }, { autoAlpha: 1, duration: 0.7, ease: 'power2.out' }, at);
      } else {
        tl.fromTo(el, { autoAlpha: 0, x: -16 }, { autoAlpha: 1, x: 0, duration: 0.8 }, at);
      }
    });

    /* Pacotes de dados: um por conector marcado com [data-packet], seguindo o caminho real
       (getPointAtLength, funciona com cotovelos e curvas). Saem só depois que a linha se desenhou.
       Atributos opcionais: data-packet="#cor", data-packet-r="4". Nunca use translateX (lições A7).
       Regra: TODO conector do mesmo caminho (mesma cor/papel) recebe data-packet, não só os retos. */
    (this.loops || []).forEach(t => t.kill());
    this.loops = [];
    slide.querySelectorAll('.packet-dot').forEach(d => d.remove());
    slide.querySelectorAll('[data-packet]').forEach((path, i) => {
      const len = path.getTotalLength();
      const dot = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
      dot.setAttribute('r', path.dataset.packetR || 4);
      dot.setAttribute('fill', path.dataset.packet || '#9fffc6');
      dot.setAttribute('class', 'packet-dot');
      dot.style.opacity = 0;
      path.after(dot);
      const o = { p: 0 };
      const place = () => { const pt = path.getPointAtLength(o.p * len); dot.setAttribute('cx', pt.x); dot.setAttribute('cy', pt.y); };
      place();
      const drawnAt = base + Number(path.dataset.seq || 0) * step + Number(path.dataset.dur || 0.55);
      const loop = g.timeline({ repeat: -1, repeatDelay: 0.5, delay: drawnAt + 0.15 + (i % 3) * 0.3 });
      loop.set(dot, { opacity: 1 })
          .to(o, { p: 1, duration: Math.max(0.7, len / 200), ease: 'power1.inOut', onUpdate: place })
          .to(dot, { opacity: 0, duration: 0.15 })
          .set(o, { p: 0, onComplete: place });
      this.loops.push(loop);
    });

    slide.querySelectorAll('[data-count]').forEach(el => {
      const target = Number(el.dataset.count);
      const o = { v: 0 };
      tl.to(o, { v: target, duration: 1.8, ease: 'power3.out', onUpdate: () => { el.textContent = fmt(o.v); } }, 0.3);
    });
  }
}
const deck = new SlidePresentation();

/* ===========================================
   MODO EDIÇÃO (E ou canto superior esquerdo): edita textos, salva no navegador, Ctrl+S baixa o HTML
   =========================================== */
(() => {
  const toggle = document.getElementById('editToggle');
  const hot = document.getElementById('editHotzone');
  const SLUG = (document.title || 'deck').toLowerCase().normalize('NFD').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  const KEY = `apthtml-edits-${SLUG}-v1`;
  const editable = () => deck.stage.querySelectorAll('h1,h2,h3,p,.h4,.tag,.kicker,.stat,.stat-l,.unit,.desc,.feat span,.chip .k,.chip .d,.tlabel,.l');
  let on = false, hide = null;
  try { const saved = JSON.parse(localStorage.getItem(KEY) || 'null'); if (saved) editable().forEach((el, i) => { if (saved[i] != null) el.innerHTML = saved[i]; }); } catch (e) {}
  const save = () => { try { localStorage.setItem(KEY, JSON.stringify([...editable()].map(el => el.innerHTML))); } catch (e) {} };
  const set = v => {
    on = v; document.body.classList.toggle('editing', v);
    toggle.classList.toggle('active', v); toggle.textContent = v ? 'Editando (E para sair)' : 'Editar texto';
    editable().forEach(el => { el.contentEditable = v ? 'true' : 'false'; });
    if (!v) { save(); toggle.classList.remove('show'); }
  };
  toggle.onclick = () => set(!on);
  hot.onclick = () => set(!on);
  const show = () => { clearTimeout(hide); toggle.classList.add('show'); };
  const later = () => { hide = setTimeout(() => { if (!on) toggle.classList.remove('show'); }, 400); };
  hot.onmouseenter = show; hot.onmouseleave = later; toggle.onmouseenter = show; toggle.onmouseleave = later;
  document.addEventListener('input', save);
  document.addEventListener('keydown', e => {
    if ((e.key === 'e' || e.key === 'E') && !e.target.isContentEditable && !e.metaKey && !e.ctrlKey) set(!on);
    if ((e.metaKey || e.ctrlKey) && e.key === 's') {
      e.preventDefault(); if (on) set(false);
      const blob = new Blob(['<!DOCTYPE html>\n' + document.documentElement.outerHTML], { type: 'text/html' });
      const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = `${SLUG}.html`; a.click();
    }
  });
})();
