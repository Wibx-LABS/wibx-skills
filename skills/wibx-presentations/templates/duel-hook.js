/* Padrão CONFRONTO ("um minuto de operação"): dois lados, mesma linha do tempo, blocos surgindo
   no instante real, CORRENTE que se revela do bloco anterior até o novo (clip-path, elos sem deformar),
   contadores ao vivo (processadas + número de blocos). Validado: Cliente x Ethereum (2026-09-26).
   Entrada: reset() SÍNCRONO deixa tudo vazio no 1º quadro (lições C3); frase-resumo sem data-r (dono = hook).
   Uso: copie o <section> de duel-slide.html; posições: left_bloco = t*(700/60) - 56; corrente entre blocos:
   left = bloco_anterior + 58, width = distância - 60. Cole este JS num <script> ANTES do script do
   controller.js (ele lê window.deckHooks ao entrar no slide) e o CSS de duel.css no <style>.
   Requer controller.js com hooks (data-hook="duel"). */
/* ===========================================
   HOOK "duel": um minuto de operação, Ethereum x Nossa rede.
   60 s simulados em 12 s reais (SPEED 5). Blocos surgem no instante data-t de cada lado;
   a partir do 1º bloco, a corrente (.duel-link[data-to]) se revela do bloco anterior até o novo
   e só então o bloco novo aparece. Contadores: processadas = blocos x tx/bloco; número de blocos.
   =========================================== */
window.deckHooks = window.deckHooks || {};
window.deckHooks.duel = (slide, g) => {
  const SPEED = 5, T = 60, LINK = 0.3;
  const fmt = n => Math.round(n).toLocaleString('pt-BR');
  const clock = slide.querySelector('.duel-clock b');
  const sides = [...slide.querySelectorAll('.duel-side')].map(el => ({
    el, tx: Number(el.dataset.tx),
    blocks: [...el.querySelectorAll('.duel-blk')].map(b => ({ b, t: Number(b.dataset.t) })),
    links: [...el.querySelectorAll('.duel-link')].map(l => ({ l, t: Number(l.dataset.to) })),
    proc: el.querySelector('[data-proc]'), count: el.querySelector('[data-blocks]'),
  }));
  const sum = slide.querySelector('.duel-sum');
  const o = { t: 0 };
  /* Estado VAZIO aplicado já na entrada do slide (síncrono, antes do 1º quadro pintado).
     Sem isso, durante o delay da timeline aparece o HTML estático = quadro FINAL (lições C3). */
  const reset = () => {
    o.t = 0;
    sides.forEach(sd => {
      sd.blocks.forEach(({ b }) => g.set(b, { autoAlpha: 0, y: 14, scale: 0.9 }));
      sd.links.forEach(({ l }) => g.set(l, { clipPath: 'inset(0 100% 0 0)' }));
      sd.proc.textContent = '0';
      sd.count.textContent = '0';
    });
    g.set(sum, { autoAlpha: 0 });
    clock.textContent = '00:00';
  };
  reset();
  const tl = g.timeline({ repeat: -1, repeatDelay: 3, delay: 1.1 });
  const render = () => {
    const s = Math.min(T, o.t);
    clock.textContent = `00:${String(Math.floor(s)).padStart(2, '0')}`.replace('00:60', '01:00');
    sides.forEach(sd => {
      const made = sd.blocks.filter(x => x.t <= s).length;
      sd.proc.textContent = fmt(made * sd.tx);
      sd.count.textContent = made;
    });
  };
  tl.call(() => { o.t = 0; render(); }, null, 0);
  sides.forEach(sd => {
    sd.blocks.forEach(({ b }) => tl.set(b, { autoAlpha: 0, y: 14, scale: 0.9 }, 0));
    sd.links.forEach(({ l }) => tl.set(l, { clipPath: 'inset(0 100% 0 0)' }, 0));
  });
  tl.set(sum, { autoAlpha: 0 }, 0);
  tl.to(o, { t: T, duration: T / SPEED, ease: 'none', onUpdate: render }, 0);
  /* Corrente: revela da esquerda (bloco anterior) para a direita (bloco novo), sem deformar os elos */
  sides.forEach(sd => sd.links.forEach(({ l, t }) => {
    tl.to(l, { clipPath: 'inset(0 0% 0 0)', duration: LINK, ease: 'power2.inOut' }, t / SPEED - 0.1 - LINK);
  }));
  sides.forEach(sd => sd.blocks.forEach(({ b, t }) => {
    tl.to(b, { autoAlpha: 1, y: 0, scale: 1, duration: 0.45, ease: 'back.out(2)' }, t / SPEED - 0.1);
    const st = b.querySelector('.st');
    tl.fromTo(st, { scale: 0 }, { scale: 1, duration: 0.3, ease: 'back.out(3)' }, t / SPEED + 0.15);
  }));
  tl.to(sum, { autoAlpha: 1, duration: 0.6 }, T / SPEED);
  return [tl];
};
