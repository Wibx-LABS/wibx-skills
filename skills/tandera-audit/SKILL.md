---
name: tandera-audit
description: Auditar e scorar qualquer site para GEO/AEO readiness (visibilidade em LLMs) com a metodologia Olho de Tandera. Acionar quando pedir para auditar site, avaliar GEO/AEO, checar robots.txt/schema/llms.txt, verificar prontidão para AI search, ou gerar relatório técnico de visibilidade em IA. Para MEDIR presença real em LLMs use tandera-sov; para ESCREVER conteúdo citável use tandera-conteudo.
---

# Tandera Audit — auditoria técnica GEO/AEO

Audita qualquer site e gera score de prontidão GEO/AEO/LLM (metodologia Olho de Tandera, WIBX LABS, recalibrada 2026-08). O harness é `audit.sh` — script curl que roda os **Blocos T, G e C** automaticamente em ~15s. O **Bloco P** (presença real em LLMs) é medido pela skill irmã `tandera-sov`.

> ⚠ **Leitura obrigatória do resultado:** rating técnico ≠ previsão de visibilidade. O score mede PRONTIDÃO técnica e CONTROLE DE NARRATIVA. A maior alavanca de citação é corpus de terceiros (earned media ≈ 84% das citações). Um site 🔴 pode ter presença perfeita (caso Magalu) e um 🟡 pode ser invisível. Detalhes: `reference/gotchas_2026.md` (ler SEMPRE antes de interpretar).

## Pré-requisitos

Só `curl` e `bash` (pré-instalados em macOS/Linux). Nenhum pacote extra.

## Run

### Passo 1 — auditoria automática

```bash
bash <caminho-desta-skill>/audit.sh <domínio> > /tmp/audit_raw.md
cat /tmp/audit_raw.md
```

`<domínio>` = domínio raiz sem `https://` (ex: `wibx.io`). O script produz score automático (T+G+C, máx 75), checklist ✅/⚠️/❌ e rating 🟢/🟡/🟠/🔴.

**Se o output disser "🚫 NÃO AUDITÁVEL via curl"**: o site bloqueia clientes não-browser (WAF/bot-block). NÃO existe score válido nesse caso — o relatório explica o que isso significa pra GEO e os próximos passos. Nunca tente "estimar" um score.

### Passo 2 — Bloco P (presença real)

Rodar a skill `tandera-sov` (protocolo estatístico de n≥5 runs, roster de engines 2026). O resultado (0-25 pts) entra manualmente no relatório final.

### Passo 3 — compor e salvar relatório

```bash
mkdir -p reports
DATE=$(date '+%Y-%m-%d')
cp /tmp/audit_raw.md "reports/${DATE}_<dominio_com_underscores>.md"
# anexar ao final o resultado do tandera-sov (Bloco P) e o Score Final = automático + P
```

Relatórios são registros históricos — acumular no projeto onde a auditoria foi pedida, nunca deletar (comparação de evolução mensal).

## Metodologia de score (v2.0 — 2026-08)

| Bloco | Itens | Pts | Fundamento |
|-------|-------|-----|------------|
| **T — Técnico** | HTTPS · robots.txt com política de AI bots por categoria (treino/search/user-fetch) · sitemap (lê declaração do robots) · HTML semântico/SSR | 30 | `reference/robots_txt_para_geo.md` |
| **G — Governança IA** | Camada de opt-out/licenciamento machine-readable (robots AI-directives / TDMRep / RSL / ai.txt) · llms.txt (máx 2, informativo) · X-Robots-Tag · checkpoints manuais (GSC AI reports/toggle; spam policy) | 15 | EU AI Act Art. 53 (enforcement 08/2026); RSL padrão oficial 12/2025 |
| **C — Conteúdo** | Title · meta description · Schema Organization+sameAs · FAQ **por schema/heading** (palavra solta não pontua) · **narrativa citável própria** (página institucional) | 30 | correlação Fase 0: on-site controla o framing |
| **P — Presença LLM** | via `tandera-sov`: awareness 10 · categoria 10 · red-team 5 | 25 | variância LLM exige n≥5 runs |
| **Total** | | **100** | |

Ratings (sobre os 75 automáticos): 🟢 ≥80% · 🟡 60-79% · 🟠 40-59% · 🔴 <40%.

Mudanças vs v1 (por quê): gate de auditabilidade (v1 pontuou página de erro 403); G caiu 25→15 (llms.txt = ruído comprovado; ai.txt perdeu pra RSL); C subiu 25→30 (narrativa própria é o que controla framing); FAQ só estrutural (v1 dava +5 por "question" em bundle JS); P subiu 20→25 (alavanca dominante).

## Smoke test (regressão)

Casos canônicos com saída esperada — rodar após qualquer mudança no script:

| Domínio | Esperado |
|---|---|
| `example.com` | score baixo, 🔴 (controle inferior) |
| `stripe.com` | schema Organization+sameAs +10; rating 🟡+ |
| `magazineluiza.com.br` | **"🚫 NÃO AUDITÁVEL via curl"**, exit 0, zero score |
| `g1.globo.com` | roda até o fim SEM crash (site sem header `server:` — regressão do bug v1) |

Verificado 2026-08-02: example 15/75 🔴 · stripe 50/75 🟡 · magalu NÃO AUDITÁVEL · g1 37/75 🟠 exit 0.

## Gotchas

Ver `reference/gotchas_2026.md` — 13 gotchas empíricos (bot-block, Grok stealth, Pay-Per-Crawl, llms.txt auto-gen vazando página com senha, SPA/schema falso-negativo, spam policy, GSC toggle…). Não interpretar relatório sem ler.

## Troubleshooting

| Sintoma | Causa | Fix |
|---------|-------|-----|
| `curl: (6) Could not resolve host` | domínio inválido/sem DNS | usar domínio raiz sem path |
| "NÃO AUDITÁVEL" mas site abre no browser | bot-block WAF/CDN | é o comportamento correto; auditar via logs de CDN se houver acesso |
| Schema não detectado em site React | CSR sem SSR (curl não executa JS) | `curl -sL <url> \| grep 'ld+json'`; verificar prerender |
| Score 0 em site no ar | redirect pra HTTP ou timeout | `curl -I https://dominio` manual |
