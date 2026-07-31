# Manual: Wibx Blueprint Skill

---

#### 🇺🇸 English
**What it does:**
This skill produces the full WiBX Project Blueprint — the house-standard B2B proposal document — from just two parameters: the target company's homepage and the destination Notion page URL. It crosses the company's documented pains against WiBX capabilities, proves media savings with sourced numbers, and writes the finished document **inside** the existing Notion page.

**Key Features:**
- **Four Sequential Phases:** Setup/enrichment → Diagnosis → Market & Costs → Cross-analysis and final doc. Each phase consumes the previous one; they are not reorderable or skippable.
- **Parallel Fan-Out for Cost:** Phases 1 and 2 launch 4 and 3 `general-purpose` subagents respectively, all in one message. Subagents return compact `fact | source | year` bullets — never prose — because their return lands in the main context and prose costs tokens for nothing.
- **Phase 3 Stays Single-Threaded:** The cross-analysis needs both artifacts whole in context, so it deliberately uses no subagents.
- **Sourced or Flagged:** Every figure carries source and year, currency conversions are explicit, and a CONFIDENCE column marks proxies. Research gaps and channels not found are collected in a `## GAPs` section per artifact and reported in chat — they never leak into the board-facing Notion body.
- **Reviewable Intermediates:** `DIAGNOSTICO_<EMPRESA>.md` and `MERCADO_<EMPRESA>.md` land in `blueprints/<EMPRESA>/` so you can audit the research before the final write.
- **Writes In Place:** Uses `notion-update-page` on the page you gave it, never creating a child subpage; long documents are appended across multiple calls.
- **One Question Only:** A single `AskUserQuestion` confirms sector, WiBX partners, scope of fronts, and optional context source — then it runs.

**Usage:**
`/wibx-blueprint <company-homepage> <notion-page-url>`. Missing either parameter, it asks before starting.

---

#### 🇧🇷 Português
**O que faz:**
Esta skill produz o WiBX Project Blueprint completo — o documento de proposta B2B padrão da casa — a partir de apenas dois parâmetros: a homepage da empresa alvo e a URL da página Notion destino. Cruza as dores documentadas da empresa com as capacidades WiBX, prova economia de mídia com números e fontes, e escreve o documento final **dentro** da página Notion existente.

**Principais Recursos:**
- **Quatro Fases Sequenciais:** Setup/enriquecimento → Diagnóstico → Mercado e Custos → Cruzamento e doc final. Cada fase consome a anterior; não dá para reordenar nem pular.
- **Fan-Out Paralelo por Economia:** As Fases 1 e 2 lançam 4 e 3 subagents `general-purpose` respectivamente, todos numa mensagem só. Os subagents devolvem bullets compactos `fato | fonte | ano` — nunca prosa — porque o retorno cai no contexto principal e prosa custa token à toa.
- **Fase 3 Fica Single-Thread:** O cruzamento precisa dos dois artefatos inteiros em contexto, então de propósito não usa subagent.
- **Com Fonte ou Sinalizado:** Todo número carrega fonte e ano, conversões cambiais são explicitadas, e uma coluna CONFIANÇA marca os proxies. GAPs de research e canais não encontrados são reunidos numa seção `## GAPs` por artefato e reportados no chat — nunca vazam para o corpo Notion, que é voz de board.
- **Intermediários Revisáveis:** `DIAGNOSTICO_<EMPRESA>.md` e `MERCADO_<EMPRESA>.md` ficam em `blueprints/<EMPRESA>/`, então dá para auditar a pesquisa antes da escrita final.
- **Escreve no Lugar:** Usa `notion-update-page` na página que você passou, nunca criando subpágina filha; documento longo é quebrado em várias chamadas de append.
- **Uma Pergunta Só:** Um único `AskUserQuestion` confirma setor, parceiros WiBX, escopo de frentes e fonte de contexto opcional — depois roda sozinha.

**Uso:**
`/wibx-blueprint <homepage-da-empresa> <url-da-pagina-notion>`. Faltando um dos dois, ela pergunta antes de começar.
