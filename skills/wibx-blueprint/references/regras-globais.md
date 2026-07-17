# Regras globais do WiBX Project Blueprint

Valem para as 3 fases, para todo subagent e para o doc final. Permanentes, nunca quebrar.

## Idioma e estilo

- Português do Brasil.
- NUNCA usar o caractere travessão em nenhum lugar. Usar vírgula, ponto, parênteses ou
  dois-pontos.
- Listas dentro de célula de tabela ou qualquer campo multi-item: sempre bullet, um item por
  linha. Nunca prosa separada por vírgula.
- Descrever a empresa cliente de forma factual e direta (quem é, o que faz, qual a escala).
  Zero tom elogioso ou bajulador.

## Voz do documento final (corpo Notion)

O corpo escrito no Notion é peça de board, não apêndice de pesquisa. Voz assertiva de quem
fecha negócio, não de analista hedgeando.

- O rigor de pesquisa (fonte, ano, câmbio) fica NO corpo, mas o aparato de incerteza NÃO.
- Coluna CONFIANÇA e flags de proxy: colapsar numa nota de metodologia única e curta por
  tabela (italico, uma linha), não numa coluna que polui o board.
- GAPs, canais não encontrados, dados de baixa confiança: vão SÓ para o report no chat ao
  final, nunca para o corpo Notion. O board vê afirmação sourced, não o buraco.
- Preferir a frase concreta à ressalva. "Redução de 61% a 98% no clique" vence "n/a por CPC,
  proxy EUA sinalizado" dentro do corpo.
- Os artefatos intermediários (`DIAGNOSTICO_*.md`, `MERCADO_*.md`) guardam TODO o rigor,
  proxies, confiança e GAP. É lá que a defesa mora, não no slide.

## Evidência

- Toda afirmação de mercado, número ou benchmark precisa de fonte com ano. Deep research via
  web_search/WebFetch, não de memória.
- Conversão cambial sempre explicitada (taxa e data), uma vez, em nota da tabela.
- Fonte hyperlinkada: quando a URL é conhecida, a célula ou citação de FONTE usa link markdown
  `[Fonte](url)`, não texto puro. Subagents devolvem a URL junto (ver bloco abaixo).
- Marcar confiança e proxies nos ARTEFATOS intermediários. No corpo Notion, ver regra de voz.

## Tese central e modelo de receita (invariante)

O núcleo argumentativo é sempre o mesmo: as frentes não são opções soltas, são um sistema
único onde o WBX é o denominador comum.

Como a WiBX ganha (explicitar sempre, é a resposta de dinheiro do board):
- A WiBX não vende software. Ganha como sócia da plataforma e nas taxas internas de
  movimentação da moeda: cada movimentação de WBX gera taxa.
- As frentes geram compra de WBX a mercado (fundo de recompensa, mídia de engajamento) e
  movimentam o ativo. Mais uso do sistema, mais giro, mais receita.

Fecho de board (o "o que fura no board"): as frentes não pedem que o cliente construa
audiência, canal ou infraestrutura. Elas PLUGAM a demanda que o cliente já gera em ativos
WiBX que já operam (Hub, Bora, Music Lovers, UAU Caixa, Token Engine). Investimento marginal,
alcance de escala. Isso reduz o risco percebido a quase zero, que é o que trava board.

## Notion craft (obrigatório no corpo final)

Ler o spec `notion://docs/enhanced-markdown-spec` antes de escrever. Padrões da casa:

- Callout de capa 🥷🏽 com spans de cor: autor em `<span color="green">`, labels
  (NATUREZA, TESE CENTRAL, etc) em `<span color="yellow">`, a frase-tese central em
  `<span color="blue">`. Capa monocromática é erro.
- Convenção de lead-in no corpo: usar `🔹 **Label:**` para abrir itens de destaque
  (conteúdo, leitura estratégica, decisor natural), não `**Label:**` pelado.
- Tabela de canais oficiais na seção "Quem é a empresa": colunas "CANAL" e "LINK" em CAPS
  bold, colgroup 225/444, emoji por tipo de canal. Pesquisar canais reais antes. Canais não
  encontrados: não listar no doc, reportar no chat.
- Emoji por linha nas tabelas de marca e de vertical (💄 Carmed, 💊 Lavitan, 🧴 higiene).
- `fit-page-width="true"` em toda tabela larga (benchmark, matriz, verticais).
- Fences de diagrama plain text usam a tag de linguagem ```plain text (não fence pelada).
- Callout "o que fura no board" / "resposta ao CFO" usa ícone 🥷 (assinatura da casa, amarra
  na capa), não 🎯.
- Mermaid do modelo operacional (Times) é estilizado: `flowchart TD` com paleta `classDef`
  por nível (reusar tokens da skill `wibx-brand`), não flowchart pelado sem cor.
- Renderizar TABELA a partir dos dados dos artefatos. Nunca achatar em prosa uma matriz que o
  diagnóstico já capturou (matriz marca x rede, personalidades). Se virou tabela na Fase 1,
  continua tabela na Fase 3.
- O documento final é escrito com `notion-update-page` DENTRO da página existente informada.
  NUNCA criar subpágina filha.

## Bloco para prompts de subagent

Cole isto em todo prompt de subagent de research:

```
Regras: responder em português do Brasil. Nunca usar travessão. Toda afirmação com fonte e
ano (buscar na web, não de memória). Factual, zero tom elogioso. Devolver APENAS bullets
compactos no formato `fato | [fonte](url) | ano`, incluindo a URL real da fonte no link
markdown, sem introdução, sem conclusão, sem prosa. Quando houver quote textual relevante
(porta-voz, executivo), incluir o quote entre aspas no bullet. Dado não encontrado: reportar
como GAP explícito, nunca inventar.
```
