---
name: wibx-blueprint
description: >-
  Gera o documento WiBX Project Blueprint completo (padrão house, equivalente ao doc Cimed)
  a partir de 2 parâmetros: o link da homepage da empresa alvo e a URL da página Notion destino.
  Orquestra 3 fases encadeadas de deep research (Diagnóstico, Mercado e Custos, Cruzamento de
  Oportunidades) com subagents paralelos para economizar tokens, e escreve o resultado final
  DENTRO da página Notion via notion-update-page. Use sempre que o usuário pedir um blueprint,
  project blueprint, pesquisa/diagnóstico de empresa para prospecção WiBX, cruzamento de
  oportunidades, ou passar um site de empresa + página Notion pedindo o documento de projeto.
  Dispara em "blueprint da empresa X", "/wibx-blueprint link notion", "faz o diagnóstico da
  empresa X", "prospecta essa empresa", "monta o doc de projeto".
---

# WiBX Blueprint

Produz o WiBX Project Blueprint: documento de proposta B2B que cruza as dores de uma empresa
alvo com as capacidades WiBX, prova economia de mídia com fontes, e escreve tudo numa página
Notion existente. Trabalho em 4 fases sequenciais. Cada fase depende da anterior, não pule
nem reordene.

**Antes de qualquer fase**: leia `references/regras-globais.md`. As regras lá valem para todo
texto produzido (seu e dos subagents) e para o doc final. Inclua o bloco de regras nos prompts
de todos os subagents.

## Parâmetros

- `<link>`: homepage oficial da empresa alvo
- `<notion>`: URL da página Notion onde o doc final será escrito

Faltando um dos dois, pergunte antes de começar.

## Fase 0: Setup e enriquecimento

1. WebFetch da homepage. Extraia: nome da empresa (`EMPRESA_ALVO`), setor provável (`SETOR`),
   pistas de marcas/produtos e canais no rodapé.
2. UMA chamada de AskUserQuestion confirmando:
   - `SETOR` inferido (opção de corrigir)
   - `PARCEIROS_WIBX` (default: "MINU (nuvem de benefícios), sem CORE")
   - `ESCOPO_FRENTES` (default: "3 frentes: Captura de Dado 1P via API, Mídia de Engajamento
     no Hub, White Label cross-marca")
   - `FONTE_CONTEXTO` opcional (ata, doc de referência, ou pesquisar do zero)
3. Buscar dados internos WiBX: leia `references/config.md` e faça notion-fetch das URLs de
   precificação e cases. Puxar a planilha de precificação COMPLETA (as 7 linhas do schema em
   config.md, não só clique e lead) e a tabela de cases COM números. URL placeholder ou fetch
   falhou: tente notion-search. Nada encontrado: use o fallback nível 2 e registre a
   precificação incompleta e os cases sem número como BLOQUEADORES de qualidade no report
   final (não são GAPs menores: derrubam a força do doc para board).
4. Crie o diretório de trabalho `blueprints/<EMPRESA_ALVO>/` no cwd. Os artefatos
   intermediários vivem ali, revisáveis pelo usuário.

## Fase 1: Diagnóstico

Output: `blueprints/<EMPRESA_ALVO>/DIAGNOSTICO_<EMPRESA_ALVO>.md`

Leia `references/prompt-1-diagnostico.md` (o spec completo das seções). Para o research,
lance 4 subagents `general-purpose` EM PARALELO (uma mensagem, 4 tool calls), cada um com
WebSearch/WebFetch e o bloco de regras globais. Instrua cada um a devolver APENAS bullets
compactos no formato `fato | fonte | ano` (zero prosa, zero introdução: o retorno volta ao
seu contexto e prosa custa tokens à toa):

- **Agent A, empresa factual**: porte, faturamento, market share, fundação, estrutura
  societária, liderança, capilaridade, colaboradores, infraestrutura, P&D, metas, rankings.
- **Agent B, canais e marcas**: canais oficiais reais (site, Instagram, TikTok, YouTube,
  LinkedIn, Facebook) confirmados por cruzamento (bio oficial, selo de verificação, link no
  rodapé do site); portfólio de marcas com público e objetivo de mídia declarado por marca;
  matriz marca x rede social se houver submarcas. Reportar explicitamente canais NÃO
  encontrados.
- **Agent C, personalidades e campanhas ativas**: executivos-creator, embaixadores,
  porta-vozes (audiência por faixa, conteúdo, papel, e QUOTE textual quando houver, capturar
  sempre); nomear candidato a "decisor de porta de entrada". Além disso, levantar as campanhas
  e ativações EM CURSO do cliente (nome próprio da ação, fonte), que vão ancorar as frentes.
  Se o setor não tiver personalidades relevantes, devolver "não aplicável" com justificativa.
- **Agent D, dores estruturais**: dores documentadas do cliente (notícias, resultados,
  entrevistas, relatórios setoriais), candidatas a 3 blocos temáticos, cada uma ancorada em
  fato com fonte e ano.

Você (main thread) consolida os retornos no formato do Prompt 1: numere as dores, monte as
tabelas (matriz marca x rede como GRID, personalidades com quote e decisor de entrada,
campanhas ativas nomeadas), registre GAPs e canais não encontrados numa seção `## GAPs` ao
final do arquivo (essa seção alimenta o report final no chat, não vai para o Notion).

## Fase 2: Mercado e Custos

Output: `blueprints/<EMPRESA_ALVO>/MERCADO_<EMPRESA_ALVO>.md`

Leia `references/prompt-2-mercado.md` e o DIAGNOSTICO da Fase 1. Lance 3 subagents
`general-purpose` EM PARALELO, mesmo formato de retorno compacto:

- **Agent A, gasto de mídia**: tamanho do investimento em mídia digital BR e do setor,
  desperdício de verba (impressão sem atenção), posição do setor na curva de CPM. Tudo com
  fonte e ano.
- **Agent B, benchmarks por métrica**: custo de mercado (faixa) para lead/cadastro, clique,
  pesquisa respondida, view (YouTube/Reels/TikTok), like, compartilhamento DM, download de
  app. Fonte e ano por linha, conversão cambial explicitada (USD para BRL com taxa e data).
- **Agent C, regulação e verticais**: como a regulação do setor (ANVISA, BACEN, CVM, o que
  couber) encarece ou restringe mídia paga; CPC de mercado por vertical em que o cliente
  atua, com fonte e ano.

Você consolida: tabelas mercado vs WiBX usando a precificação obtida na Fase 0 (WiBX é flat,
mercado não; a redução é maior nas verticais caras e reguladas), coluna CONFIANÇA
(Alta/Média/Baixa) e proxies sinalizados, tabela de cases reais (Sebrae, Americanas, Banco
Pan e o que a página de cases trouxer), fechamento "o que fura no board" (por que cada
percentual é conservador; a única variável em aberto é o volume de verba do cliente).
Seção `## GAPs` ao final.

## Fase 3: Cruzamento e doc final

Output: escrito DENTRO da página Notion `<notion>`.

Esta fase roda no main thread (o cruzamento precisa dos dois artefatos inteiros em contexto).

1. Leia `references/prompt-3-cruzamento.md` (estrutura obrigatória do doc, na ordem).
2. Leia o spec de markdown enriquecido do Notion (`notion://docs/enhanced-markdown-spec` via
   ReadMcpResourceTool) ANTES de escrever: toggles, tabelas com colgroup, callouts, plain
   text blocks e mermaid têm sintaxe própria. Aplique o Notion craft de `regras-globais.md`
   (spans de cor na capa, 🔹 lead-in, emoji por linha, fit-page-width, fence ```plain text,
   callout 🥷 no "o que fura no board", mermaid estilizado com classDef).
3. Componha o documento: o coração é o cruzamento de cada dor numerada do diagnóstico com os
   dados de custo do mercado, transformados em vetores de valor e frentes encadeadas. O
   núcleo argumentativo nunca muda: as frentes não são opções soltas, são um sistema único
   onde o WBX é o denominador comum; a WiBX ganha gerando compras a mercado de WBX e
   movimentando o ativo (taxa por movimentação). Renderize os dados dos artefatos como TABELA,
   nunca ache em prosa uma matriz que a Fase 1 já capturou. Voz de board, não de apêndice de
   pesquisa: confiança/proxy/GAP ficam nos artefatos e no report de chat, não no corpo Notion
   (ver regras-globais voz).
4. Escreva com `notion-update-page` DENTRO da página `<notion>`. NUNCA crie subpágina filha.
   Documento longo: quebre em múltiplas chamadas de update-page (append) se necessário.
5. Reporte no chat: GAPs de research acumulados das fases 1 e 2, canais não encontrados, e
   qualquer proxy ou dado de baixa confiança usado nas tabelas.

## Economia de tokens

- Subagents devolvem bullets `fato | fonte | ano`, nunca relatório em prosa.
- Fases 1 e 2 fazem fan-out paralelo; a Fase 3 não usa subagent (precisa do contexto todo).
- Não recarregue references já lidos na sessão.
