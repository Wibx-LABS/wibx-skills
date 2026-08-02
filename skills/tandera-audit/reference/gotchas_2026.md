# Gotchas de auditoria GEO — atualização 2026-08 (Fase 0)

Achados empíricos da bateria de 9 domínios + market check (LABS, 2026-08-02). Ler antes de interpretar qualquer relatório do `audit.sh`.

1. **Bot-block 403 (WAF/Akamai/Cloudflare)** — o script emite "NÃO AUDITÁVEL" e NUNCA score. Caso real: magazineluiza.com.br responde 403 a curl e tem presença perfeita em LLMs. Score baixo em site bloqueado seria mentira dupla. Crawlers de IA tendem a sofrer o mesmo block — a auditoria real ali é de política de WAF, via logs de CDN.
2. **Rating técnico ≠ previsão de visibilidade.** Evidência Fase 0: Nubank 38 e Magalu (inauditável) com presença perfeita; ~84% das citações de IA vêm de earned media (MuckRack). O técnico controla o FRAMING (que narrativa própria existe pra citar), não a existência da citação.
3. **Grok/xAI crawleia com IP residencial rotativo e user-agent falsificado** (Safari/Chrome) — robots.txt é inócuo contra ele; só defesa edge/WAF.
4. **Perplexity segue fora do Verified Bot Program da Cloudflare** (stealth crawling documentado) — bloquear `PerplexityBot` no robots não garante bloqueio real.
5. **Cloudflare Pay-Per-Crawl**: desde 15/09/2026, block por default de crawlers "mixed-use" em páginas com ads — um site atrás de Cloudflare pode ter sumido pros bots sem ninguém ter decidido isso. Checar painel Cloudflare do cliente.
6. **llms.txt**: ~10% de adoção, mas 97% dos arquivos recebem ZERO requests de AI; estudo SE Ranking: ruído, não sinal, pra citação. Só vale em propriedade de DOCUMENTAÇÃO (agentes de código consomem). Auto-gerado por plugin Hostinger/WordPress pode vazar páginas protegidas por senha (caso real: musiclovers.app listava página com senha).
7. **Opt-out machine-readable é obrigação de quem treina, não de quem publica** — mas EU AI Act Art. 53 (enforcement desde 02/08/2026) fez o opt-out publicado ter efeito legal. Ordem de preferência 2026: robots AI-directives > RSL (Reddit/Yahoo/Medium; suporte Cloudflare/Akamai/IAB) > TDMRep > ai.txt (estagnado).
8. **Distinção treino × search × user-fetch é a decisão editorial central**: bloquear bots de SEARCH (OAI-SearchBot, Claude-SearchBot, PerplexityBot) = sumir das citações; bloquear só TREINO (GPTBot, Google-Extended, CCBot, Meta-ExternalAgent, Applebot-Extended, Bytespider) preserva citação e nega treino.
9. **Yoast/WordPress permissivo**: `User-agent: * / Disallow:` (vazio) = permite tudo — o script pontua 3 (existe, sem decisão de AI), não 10.
10. **Schema em SPA/CSR**: curl não executa JS; schema injetado via JS = falso negativo possível. Confirmar com `curl -sL <url> | grep 'ld+json'` e, se SPA, verificar SSR/prerender.
11. **Google spam policy (05/2026)** cobre "manipulação de respostas generativas" — AI answer stuffing virou risco de penalização. Red flag, não técnica.
12. **Search Console (06/2026)**: relatórios de impressões em AI Overviews/AI Mode + toggle de exclusão de AI. Sempre checar o estado do toggle — exclusão ligada explica invisibilidade em AIO.
13. **76% das páginas citadas em AI Overviews estão no top-10 orgânico** (Ahrefs, 1,9M citações) — SEO clássico continua sendo o caminho pra AIO; não existe atalho "GEO-only" na superfície Google.
