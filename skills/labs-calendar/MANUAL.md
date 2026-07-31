# Manual: LABS Calendar Skill

---

#### 🇺🇸 English
**What it does:**
This skill is the direct bridge for putting **any** item into the LABS Calendar (Notion) — a to-do, a task, a meeting, a delivery, a milestone or a generic event — for any Wibx area (DEV/TI, Marketing, CRIAÇÃO, CS/Suporte, Comercial, PMO, Financeiro, Admin). One item becomes one page in the LABS Calendar database, which shows up on the team's calendar view.

**Key Features:**
- **Asks Instead of Guessing:** Title, Date and Area are mandatory. If any is missing it stops and asks — per the WIBX rule against inferring required fields. Type defaults to `Afazer`.
- **Structured Body per Type:** Each type ships its own template — To-do gets Context + Definition of Done, Delivery gets what/for whom/acceptance/link, Milestone gets what it marks + blockers.
- **AI Meeting Notes on Every Meeting:** Meetings always end with the `<meeting-notes>` block, which creates Notion's native recording card so the team hits record straight from the page. The spec is finicky (tab indentation, no `<summary>`/`<transcript>`) and the skill encodes it.
- **Date Handling:** Day-only, day+time, or a start/end interval — all in Brazil time (`-03:00`), with relative dates ("Thursday", "the 25th") resolved to absolute ones.
- **Multi-Select Gotcha Documented:** `Tags` only accepts already-registered options. Adding a new one is a schema change on a shared database, requires listing every existing option in the `SET`, and needs Pedro's OK first.
- **Confirms Before Writing:** Echoes a one-line summary (`"<Title>" · <date> · [<area>, <type>]`) so a wrong date or area gets caught before the page exists, and returns the created page URL.

**Note:** This is for one-off items. The weekly per-department focus routine is the runbook `05_runbooks/rotina_labs_calendario.md`, not this skill.

---

#### 🇧🇷 Português
**O que faz:**
Esta skill é a ponte direta para subir **qualquer** item no LABS Calendar (Notion) — afazer, tarefa, reunião, entrega, marco ou evento genérico — para qualquer área da Wibx (DEV/TI, Marketing, CRIAÇÃO, CS/Suporte, Comercial, PMO, Financeiro, Admin). Um item vira uma página no database LABS Calendar, que aparece na view de calendário do time.

**Principais Recursos:**
- **Pergunta em Vez de Inferir:** Título, Data e Área são obrigatórios. Faltando qualquer um, ela para e pergunta — conforme a regra WIBX de não inferir campo obrigatório. Tipo tem default `Afazer`.
- **Corpo Estruturado por Tipo:** Cada tipo tem seu template — Afazer ganha Contexto + Critério de pronto, Entrega ganha o quê/para quem/aceite/link, Marco ganha o que marca + bloqueios.
- **AI Meeting Notes em Toda Reunião:** Reunião sempre termina com o bloco `<meeting-notes>`, que cria o card de gravação nativo do Notion — o time aperta gravar direto na página. A spec é chata (indentação com tab, sem `<summary>`/`<transcript>`) e a skill já a codifica.
- **Tratamento de Data:** Só dia, dia+hora, ou intervalo início/fim — tudo no fuso Brasil (`-03:00`), com datas relativas ("quinta", "dia 25") resolvidas para absolutas.
- **Gotcha do Multi-Select Documentado:** `Tags` só aceita opções já cadastradas. Cadastrar uma nova é mudança de schema em database compartilhado, exige listar todas as opções existentes no `SET`, e precisa de OK do Pedro antes.
- **Confirma Antes de Escrever:** Ecoa um resumo de uma linha (`"<Título>" · <data> · [<área>, <tipo>]`) para pegar data ou área errada antes da página existir, e devolve a URL da página criada.

**Nota:** Esta skill é para itens avulsos. A rotina semanal de foco por departamento é o runbook `05_runbooks/rotina_labs_calendario.md`, não esta skill.
