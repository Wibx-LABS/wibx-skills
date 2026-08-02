#!/usr/bin/env bash
# Olho de Tandera — Technical Audit Script v2.0
# Usage: ./audit.sh <domain>
# Example: ./audit.sh wibx.io
# Output: Structured report in Markdown (stdout)
#
# v2.0 (2026-08): auditability gate (bot-block => no score), sitemap via robots
# declaration, FAQ by schema/heading only, robots posture by bot category,
# score rebalanced T30/G15/C30/P25 per Fase 0 report (LABS, 2026-08-02).

set -euo pipefail

DOMAIN="${1:-}"
if [[ -z "$DOMAIN" ]]; then
  echo "Usage: $0 <domain>  (e.g. $0 wibx.io)" >&2
  exit 1
fi

DOMAIN="${DOMAIN#https://}"
DOMAIN="${DOMAIN#http://}"
DOMAIN="${DOMAIN%%/*}"

BASE="https://${DOMAIN}"
SCORE=0
MAX_SCORE=0
REPORT=""
SCORE_T=0
SCORE_G=0
SCORE_C=0
CURRENT_BLOCK=""

# ─── helpers ────────────────────────────────────────────────────────────────
log()  { echo "[INFO] $*" >&2; }
pass() {
  SCORE=$((SCORE + $1))
  case "$CURRENT_BLOCK" in
    T) SCORE_T=$((SCORE_T + $1)) ;;
    G) SCORE_G=$((SCORE_G + $1)) ;;
    C) SCORE_C=$((SCORE_C + $1)) ;;
  esac
  REPORT+=$'\n'"✅ **$2** (+$1 pts)"
}
warn() { REPORT+=$'\n'"⚠️  **$2** ($1)"; }
fail() { REPORT+=$'\n'"❌ **$2** (-0 pts)"; }
add()  { MAX_SCORE=$((MAX_SCORE + $1)); }

section() {
  case "$*" in
    *"BLOCO T"*) CURRENT_BLOCK="T" ;;
    *"BLOCO G"*) CURRENT_BLOCK="G" ;;
    *"BLOCO C"*) CURRENT_BLOCK="C" ;;
    *"BLOCO P"*) CURRENT_BLOCK="P" ;;
  esac
  REPORT+=$'\n\n'"## $*"
}

header() {
  echo ""
  echo "# Olho de Tandera — Auditoria Técnica GEO/AEO"
  echo "> **Domínio:** \`${DOMAIN}\`"
  echo "> **Data:** $(date '+%Y-%m-%d')"
  echo ""
  echo "> ⚠ **Aviso de leitura:** rating técnico ≠ previsão de visibilidade em LLMs."
  echo "> Este score mede PRONTIDÃO técnica e CONTROLE DE NARRATIVA do site. A evidência"
  echo "> (Fase 0, 2026-08) mostra que a maior alavanca de citação é corpus de terceiros"
  echo "> (earned media ≈ 84% das citações). Meça presença real com a skill \`tandera-sov\`."
  echo ""
}

# ─── fetch helpers ───────────────────────────────────────────────────────────
http_head() {
  curl -sI --max-time 10 --location "$1" 2>/dev/null || true
}

http_get() {
  curl -sL --max-time 15 "$1" 2>/dev/null || true
}

http_code() {
  curl -so /dev/null --max-time 10 -w "%{http_code}" --location "$1" 2>/dev/null || echo "000"
}

# ─── GATE DE AUDITABILIDADE ──────────────────────────────────────────────────
# Bot-block / site fora do ar => relatório "NÃO AUDITÁVEL", NUNCA score baixo.
# (Fase 0: magazineluiza.com.br respondeu 403 e a v1 pontuou a página de erro.)
log "Pre-flight: auditability gate..."
GATE_CODE=$(http_code "$BASE")
GATE_HTML=$(http_get "$BASE")
IS_CHALLENGE=$(echo "$GATE_HTML" | grep -ci "cf-challenge\|Just a moment\|_Incapsula_\|Access Denied\|Attention Required" || true)

if [[ ! "$GATE_CODE" =~ ^2 ]] || [[ $IS_CHALLENGE -gt 0 ]]; then
  header
  echo "---"
  echo ""
  echo "## 🚫 NÃO AUDITÁVEL via curl"
  echo ""
  if [[ ! "$GATE_CODE" =~ ^2 ]]; then
    echo "- Home respondeu **HTTP ${GATE_CODE}** a um cliente curl — provável bot-block (WAF/anti-bot)."
  fi
  if [[ $IS_CHALLENGE -gt 0 ]]; then
    echo "- Corpo da resposta contém assinatura de challenge anti-bot (Cloudflare/Incapsula/afins)."
  fi
  echo ""
  echo "**Nenhum score foi emitido** — pontuar a página de bloqueio geraria um número inválido."
  echo ""
  echo "O que isso significa para GEO: os crawlers de IA (GPTBot, ClaudeBot etc.) tendem a"
  echo "sofrer o mesmo bloqueio. Verificar a política de bots do site (WAF/CDN) é o passo 1:"
  echo "um site pode estar invisível para LLMs por decisão de infraestrutura, não de conteúdo."
  echo ""
  echo "Próximos passos: (1) confirmar no navegador que o site está no ar; (2) auditar via"
  echo "logs de servidor/CDN se houver acesso; (3) rodar o Bloco P (tandera-sov) normalmente —"
  echo "presença em LLM não depende deste fetch."
  echo ""
  echo "---"
  echo "_Gerado por Olho de Tandera Audit Script v2.0 — WIBX LABS_"
  exit 0
fi

# ─── BLOCO T — TÉCNICO (30 pts) ──────────────────────────────────────────────
section "BLOCO T — Técnico (30 pts)"

add 30

# T1: HTTPS (gate já garantiu 2xx)
log "Checking HTTPS..."
pass 5 "HTTPS — site responde em HTTPS (HTTP ${GATE_CODE})"

# T2: robots.txt + postura por categoria de bot
log "Checking robots.txt..."
ROBOTS=$(http_get "${BASE}/robots.txt")
ROBOTS_CODE=$(http_code "${BASE}/robots.txt")

# Mapa de user-agents 2026 por categoria (treino × search × user-fetch)
UA_TRAIN="GPTBot|Google-Extended|CCBot|Meta-ExternalAgent|Applebot-Extended|Bytespider|ClaudeBot|Amazonbot"
UA_SEARCH="OAI-SearchBot|Claude-SearchBot|PerplexityBot"
UA_FETCH="ChatGPT-User|Claude-User|Perplexity-User"

robots_posture() {
  # $1 = regex de UAs; imprime "N UAs citados"
  echo "$ROBOTS" | grep -ciE "^User-agent: *(${1})" || true
}

if [[ "$ROBOTS_CODE" == "200" ]] && [[ -n "$ROBOTS" ]]; then
  N_TRAIN=$(robots_posture "$UA_TRAIN")
  N_SEARCH=$(robots_posture "$UA_SEARCH")
  N_FETCH=$(robots_posture "$UA_FETCH")
  N_AI=$((N_TRAIN + N_SEARCH + N_FETCH))
  HAS_DISALLOW=$(echo "$ROBOTS" | grep -ci "Disallow:" || true)

  if [[ $N_AI -gt 0 ]]; then
    pass 10 "robots.txt — política de AI bots DELIBERADA (${N_AI} user-agents de IA citados)"
    REPORT+=$'\n'"   → Postura por categoria: treino=${N_TRAIN} UAs citados · search=${N_SEARCH} · user-fetch=${N_FETCH}"
    REPORT+=$'\n'"   → NOTA: pontos por config deliberada (allow OU block). Bloquear bots de SEARCH (OAI-SearchBot, Claude-SearchBot, PerplexityBot) = sumir das citações; bloquear só TREINO preserva citação. Revisar postura contra a intenção GEO — ver reference/robots_txt_para_geo.md"
  elif [[ $HAS_DISALLOW -gt 0 ]]; then
    pass 3 "robots.txt — existe mas sem regra específica para AI bots"
    warn "parcial" "robots.txt — nenhuma decisão sobre bots de IA (postura permissiva por omissão: doa conteúdo para treino e depende de default para search)"
  else
    pass 2 "robots.txt — existe mas vazio ou mínimo"
    warn "urgente" "robots.txt — definir política explícita por categoria de bot (treino/search/user-fetch)"
  fi
else
  fail 0 "robots.txt — NÃO EXISTE (HTTP ${ROBOTS_CODE})"
  warn "crítico" "Criar robots.txt com política explícita de AI bots (ver reference/robots_txt_para_geo.md)"
fi

# T3: Sitemap — 1º a declaração no robots.txt, depois paths fixos
log "Checking sitemap..."
SITEMAP_DECL=$(echo "$ROBOTS" | grep -i "^Sitemap:" | head -1 || true)
SITEMAP_CODE=$(http_code "${BASE}/sitemap.xml")
SITEMAP_INDEX_CODE=$(http_code "${BASE}/sitemap_index.xml")

if [[ -n "$SITEMAP_DECL" ]]; then
  pass 5 "Sitemap XML — declarado no robots.txt (${SITEMAP_DECL#Sitemap: })"
elif [[ "$SITEMAP_CODE" == "200" ]] || [[ "$SITEMAP_INDEX_CODE" == "200" ]]; then
  pass 5 "Sitemap XML — presente em path padrão"
  if [[ "$SITEMAP_INDEX_CODE" == "200" ]]; then
    REPORT+=$'\n'"   → sitemap_index.xml detectado (multi-sitemap)"
  fi
else
  fail 0 "Sitemap XML — não encontrado (nem declarado no robots.txt, nem em /sitemap.xml)"
fi

# T4: SSR / HTML semântico
log "Checking SSR/HTML semantics..."
HTML="$GATE_HTML"
HAS_H1=$(echo "$HTML" | grep -ci "<h1" || true)
HAS_TITLE=$(echo "$HTML" | grep -ci "<title" || true)
HAS_META_DESC=$(echo "$HTML" | grep -ci 'meta.*name=.*description\|meta.*property=.*og:description' || true)
HAS_NAV=$(echo "$HTML" | grep -ci "<nav\|<header\|<main\|<article\|<footer" || true)
IS_SPA=$(echo "$HTML" | grep -ci "window.__NEXT_DATA__\|<div id=\"root\">\|<div id=\"app\">" || true)

if [[ $HAS_H1 -gt 0 ]] && [[ $HAS_NAV -gt 0 ]]; then
  if [[ $IS_SPA -gt 0 ]]; then
    pass 5 "HTML semântico — H1 e estrutura presentes, mas app parece SPA (pode não renderizar para bots)"
    warn "atenção" "SSR — detectado SPA framework; verificar se SSR/SSG está ativo para bots de IA"
  else
    pass 10 "HTML semântico + SSR — estrutura completa detectada (H1, nav, sem flags SPA)"
  fi
elif [[ $HAS_H1 -gt 0 ]]; then
  pass 5 "HTML semântico — H1 presente mas estrutura parcial"
  warn "atenção" "HTML — adicionar nav, main, header, footer semânticos"
else
  fail 0 "HTML semântico — sem H1 detectado; bots de IA podem não extrair conteúdo"
fi

# ─── BLOCO G — GOVERNANÇA IA (15 pts) ────────────────────────────────────────
# v2.0: rebalanceado. Critério central = camada de OPT-OUT/LICENCIAMENTO
# machine-readable (EU AI Act Art. 53 em enforcement desde 2026-08-02; OLG
# Hamburg 2025: qualquer formato machine-readable vale). llms.txt rebaixado
# (97% dos arquivos recebem zero requests de AI — ruído, não sinal).
section "BLOCO G — Governança IA (15 pts)"

add 15

# G1: camada de opt-out/licenciamento machine-readable (10 pts)
log "Checking machine-readable opt-out layer..."
OPTOUT_KINDS=""
# (a) diretivas de AI no robots.txt (já medido no T2)
N_AI_ROBOTS=$(echo "${ROBOTS:-}" | grep -ciE "^User-agent: *(${UA_TRAIN}|${UA_SEARCH}|${UA_FETCH})" || true)
[[ $N_AI_ROBOTS -gt 0 ]] && OPTOUT_KINDS+="robots-AI-directives "
# (b) TDMRep
TDMREP_CODE=$(http_code "${BASE}/.well-known/tdmrep.json")
[[ "$TDMREP_CODE" == "200" ]] && OPTOUT_KINDS+="TDMRep "
HAS_TDM_HEADER=$(http_head "$BASE" | grep -ci "tdm-reservation" || true)
[[ $HAS_TDM_HEADER -gt 0 ]] && OPTOUT_KINDS+="TDM-header "
# (c) RSL (Really Simple Licensing — padrão oficial desde 2025-12)
RSL_CODE=$(http_code "${BASE}/.well-known/rsl.xml")
HAS_RSL_ROBOTS=$(echo "${ROBOTS:-}" | grep -ci "License:" || true)
{ [[ "$RSL_CODE" == "200" ]] || [[ $HAS_RSL_ROBOTS -gt 0 ]]; } && OPTOUT_KINDS+="RSL "
# (d) ai.txt (legado, ainda conta como camada)
AITXT_CODE=$(http_code "${BASE}/ai.txt")
[[ "$AITXT_CODE" == "200" ]] && OPTOUT_KINDS+="ai.txt "

if [[ -n "$OPTOUT_KINDS" ]]; then
  pass 10 "Opt-out/licenciamento machine-readable — presente (${OPTOUT_KINDS% })"
  REPORT+=$'\n'"   → EU AI Act Art. 53 (enforcement desde ago/2026) obriga provedores GPAI a respeitar opt-outs machine-readable; qualquer formato vale (OLG Hamburg 2025)"
else
  fail 0 "Opt-out/licenciamento machine-readable — NENHUMA camada detectada (robots AI-directives / TDMRep / RSL / ai.txt)"
  warn "recomendado" "Implementar ao menos diretivas de AI bots no robots.txt; considerar RSL (padrão com adoção real: Reddit/Yahoo/Medium) para licenciamento"
fi

# G2: llms.txt (máx 2 pts — informativo)
log "Checking llms.txt..."
LLMS_CODE=$(http_code "${BASE}/llms.txt")
LLMS_CONTENT=$(http_get "${BASE}/llms.txt")
if [[ "$LLMS_CODE" == "200" ]] && [[ -n "$LLMS_CONTENT" ]]; then
  IS_AUTOGEN=$(echo "$LLMS_CONTENT" | grep -ci "Generated by Hostinger\|Generated by WordPress\|Generated by plugin" || true)
  LLMS_LEN=${#LLMS_CONTENT}
  if [[ $IS_AUTOGEN -gt 0 ]]; then
    pass 0 "llms.txt — existe mas auto-gerado por plugin (Hostinger/WordPress)"
    warn "urgente" "llms.txt auto-gerado pode expor páginas protegidas por senha — remover ou curar manualmente"
  else
    pass 2 "llms.txt — presente e curado (${LLMS_LEN} chars)"
  fi
  REPORT+=$'\n'"   → NOTA 2026-08: 97% dos llms.txt recebem ZERO requests de AI; sem evidência de efeito em citação. Só vale investimento em propriedade de DOCUMENTAÇÃO (agentes de código consomem)"
else
  fail 0 "llms.txt — não existe"
  warn "baixa prioridade" "llms.txt — irrelevante para AI search (Google não suporta; crawlers ignoram); só considerar em site de docs"
fi

# G3: X-Robots-Tag (3 pts)
log "Checking HTTP headers..."
HEADERS=$(http_head "$BASE")
HAS_X_ROBOTS=$(echo "$HEADERS" | grep -ci "x-robots-tag" || true)
PLATFORM=$(echo "$HEADERS" | grep -i "platform:\|server:\|x-powered-by:" | head -3 || true)

if [[ $HAS_X_ROBOTS -gt 0 ]]; then
  X_ROBOTS_VAL=$(echo "$HEADERS" | grep -i "x-robots-tag:" | head -1 || true)
  pass 3 "X-Robots-Tag — presente: ${X_ROBOTS_VAL}"
else
  warn "opcional" "X-Robots-Tag — não detectado; considerar para controle fino de indexação/snippets"
fi

if [[ -n "$PLATFORM" ]]; then
  REPORT+=$'\n'"   → Stack detectada: $(echo "$PLATFORM" | tr '\n' ' ' || true)"
fi

# G4: checkpoints manuais (0 pts — instrução)
warn "verificação manual" "Google Search Console — desde 06/2026 tem relatórios de impressões em AI Overviews/AI Mode E toggle de exclusão de AI features: verificar o estado do toggle e ler os relatórios"
warn "verificação manual" "Spam policy Google (05/2026) proíbe manipulação de respostas generativas — checar se o site usa 'AI answer stuffing' (red flag de penalização, não técnica)"

# ─── BLOCO C — CONTEÚDO (30 pts) ─────────────────────────────────────────────
section "BLOCO C — Conteúdo Citável (30 pts)"

add 30

# C1: Title + Meta description (5+5)
if [[ $HAS_TITLE -gt 0 ]]; then
  TITLE_VAL=$(echo "$HTML" | grep -oi '<title[^>]*>[^<]*</title>' | head -1 | sed 's/<[^>]*>//g' || true)
  pass 5 "Meta title — presente: \"${TITLE_VAL}\""
else
  fail 0 "Meta title — ausente"
fi

if [[ $HAS_META_DESC -gt 0 ]]; then
  pass 5 "Meta description — presente"
else
  fail 0 "Meta description — ausente"
  warn "atenção" "Meta description — adicionar em todas as páginas principais"
fi

# C2: Schema.org / JSON-LD (10)
log "Checking schema.org..."
HAS_SCHEMA=$(echo "$HTML" | grep -ci 'application/ld+json\|schema\.org' || true)
HAS_ORG_SCHEMA=$(echo "$HTML" | grep -ci '"Organization"\|"LocalBusiness"\|"WebSite"' || true)
HAS_SAME_AS=$(echo "$HTML" | grep -ci '"sameAs"' || true)
HAS_FAQ_SCHEMA=$(echo "$HTML" | grep -ci '"FAQPage"\|"Question"' || true)

if [[ $HAS_ORG_SCHEMA -gt 0 ]] && [[ $HAS_SAME_AS -gt 0 ]]; then
  pass 10 "Schema.org — Organization + sameAs detectados (knowledge graph anchor)"
elif [[ $HAS_SCHEMA -gt 0 ]]; then
  pass 5 "Schema.org — presente mas sem Organization/sameAs"
  warn "atenção" "Schema — adicionar Organization + sameAs (LinkedIn, Wikidata, Crunchbase) para ancorar knowledge graph"
else
  fail 0 "Schema.org — NÃO DETECTADO"
  warn "alta prioridade" "Schema — implementar Organization + sameAs; ajuda Perplexity/ChatGPT RAG"
fi

# C3: FAQ/Q&A (5) — v2.0: SÓ schema FAQPage/Question ou heading estruturado.
# (v1 dava +5 por qualquer palavra "question" em bundle JS — falso positivo sistemático.)
HAS_FAQ_HEADING=$(echo "$HTML" | grep -ciE "<h[1-4][^>]*>[^<]*(FAQ|[Pp]erguntas [Ff]requentes|[Dd]úvidas [Ff]requentes)" || true)
if [[ $HAS_FAQ_SCHEMA -gt 0 ]]; then
  pass 5 "Conteúdo FAQ/Q&A — FAQPage/Question schema detectado (extração RAG direta)"
elif [[ $HAS_FAQ_HEADING -gt 0 ]]; then
  pass 3 "Conteúdo FAQ/Q&A — seção estruturada detectada (heading), sem FAQPage schema"
  warn "atenção" "FAQ — adicionar FAQPage schema à seção existente"
else
  fail 0 "Conteúdo FAQ/Q&A — nenhuma seção estruturada detectada"
  warn "atenção" "FAQ/Q&A — estruturar perguntas e respostas auto-contidas com FAQPage schema"
fi

# C4: narrativa citável própria (5) — heurística: página institucional acessível
log "Checking self-narrative page..."
NARRATIVE_FOUND=""
for path in "/sobre" "/quem-somos" "/about" "/about-us"; do
  N_CODE=$(http_code "${BASE}${path}")
  if [[ "$N_CODE" == "200" ]]; then
    NARRATIVE_FOUND="$path"
    break
  fi
done
if [[ -n "$NARRATIVE_FOUND" ]]; then
  pass 5 "Narrativa própria — página institucional acessível (${NARRATIVE_FOUND})"
  REPORT+=$'\n'"   → Verificar MANUALMENTE se ela responde 'o que é [marca]' de forma auto-contida e citável — é a fonte que os LLMs usam para o framing da marca"
else
  fail 0 "Narrativa própria — nenhuma página institucional encontrada (/sobre, /quem-somos, /about)"
  warn "alta prioridade" "Sem narrativa citável própria, os LLMs constroem o framing da marca SÓ com fontes de terceiros (caso Wibx 2026-08: framing 'cripto-investimento' por ausência de alternativa própria)"
fi

# ─── BLOCO P — PRESENÇA LLM (25 pts — manual via tandera-sov) ────────────────
section "BLOCO P — Presença em LLMs (25 pts — medir com a skill tandera-sov)"

add 25

REPORT+=$'\n'"
> **Este bloco NÃO é medido por este script.** Use a skill \`tandera-sov\` (mesmo plugin):
> protocolo de n≥5 runs por prompt, roster de engines 2026 (ChatGPT, AI Overviews/AI Mode,
> Gemini, Meta AI/WhatsApp, Perplexity, Copilot) e mapa de fontes citadas.
>
> Composição do score P (25 pts):
> - Brand awareness: 0-10 pts (% de runs com menção neutra/positiva)
> - Category presence: 0-10 pts (% de runs em que aparece no top-3 da categoria)
> - Red-team defense: 0-5 pts (% de runs sem afirmação negativa falsa)
>
> **Inserir o resultado do tandera-sov manualmente no relatório final.**"

# ─── CÁLCULO DE SCORE ────────────────────────────────────────────────────────
TECH_SCORE=$SCORE
TECH_MAX=75  # T30 + G15 + C30 automatizáveis

echo ""
header
echo "---"
echo ""
echo "## Score Automático (Blocos T + G + C)"
echo ""
echo "| Bloco | Pontuação | Máximo |"
echo "|-------|-----------|--------|"
echo "| T — Técnico | ${SCORE_T} | 30 pts |"
echo "| G — Governança IA | ${SCORE_G} | 15 pts |"
echo "| C — Conteúdo | ${SCORE_C} | 30 pts |"
echo "| **TOTAL AUTOMÁTICO** | **${TECH_SCORE}** | **${TECH_MAX}** |"
echo "| P — Presença LLM (tandera-sov) | _manual_ | 25 pts |"
echo "| **TOTAL FINAL** | **${TECH_SCORE} + P** | **100** |"
echo ""

PCTG=$(( TECH_SCORE * 100 / TECH_MAX ))
if [[ $PCTG -ge 80 ]]; then
  RATING="🟢 EXCELENTE"
elif [[ $PCTG -ge 60 ]]; then
  RATING="🟡 BOM — gaps identificados"
elif [[ $PCTG -ge 40 ]]; then
  RATING="🟠 ATENÇÃO — remediação necessária"
else
  RATING="🔴 CRÍTICO — configuração deficiente"
fi

echo "> **Rating automático:** ${RATING} (${PCTG}% do máximo automático)"
echo ""
echo "---"

echo "$REPORT"

# ─── PRÓXIMOS PASSOS ─────────────────────────────────────────────────────────
echo ""
echo "---"
echo ""
echo "## Próximos Passos Recomendados"
echo ""
echo "1. **Política de AI bots no robots.txt** — por categoria treino/search/user-fetch (ver \`reference/robots_txt_para_geo.md\` desta skill)"
echo "2. **Narrativa citável própria** — página institucional auto-contida que responda 'o que é [marca]' (controla o framing que os LLMs reproduzem)"
echo "3. **Schema Organization + sameAs** — ancorar knowledge graph (LinkedIn, Wikidata, Crunchbase)"
echo "4. **Rodar tandera-sov** — medir presença real (Bloco P) com protocolo estatístico"
echo "5. **Camada de opt-out machine-readable** — robots AI-directives no mínimo; RSL se houver estratégia de licenciamento"
echo ""
echo "---"
echo "_Gerado por Olho de Tandera Audit Script v2.0 — WIBX LABS_"
