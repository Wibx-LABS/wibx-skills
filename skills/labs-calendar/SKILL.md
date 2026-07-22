---
name: labs-calendar
description: |
  Ponte direta para subir QUALQUER item no LABS Calendar (Notion) — afazer, tarefa, reunião,
  entrega, marco ou evento — para qualquer área da Wibx (DEV/TI, Marketing, CRIAÇÃO, CS/Suporte,
  Comercial, PMO, Financeiro, Admin). Use sempre que o usuário quiser adicionar, subir, marcar,
  agendar ou criar algo no calendário/agenda do LABS: "adiciona no calendário do LABS",
  "marca uma reunião com o Caio quinta", "sobe uma entrega pra Marketing", "agenda um afazer
  pra DEV/TI dia 25", "cria um evento no LABS Calendar", "põe isso na agenda do LABS",
  "lembra o time disso na sexta". Cria a página no database LABS Calendar com título, data
  (com hora/intervalo opcional), tags de área + tipo e um corpo estruturado. NÃO é a rotina
  semanal de foco por departamento (isso é o runbook `05_runbooks/rotina_labs_calendario.md`);
  esta skill é para itens avulsos.
---

# LABS Calendar — ponte de entrada

Cria itens no database **LABS Calendar** da página Notion WIBX LABS. Um item = uma página no
database, que aparece na view de calendário do time.

## Alvo (constantes)

- **Data source (parent):** `2e2cef37-3b56-80f4-a189-000b24e68729`
- **Database URL:** https://app.notion.com/p/2e2cef373b568008920ae7a62868a65b
- **Ferramenta de escrita:** `mcp__claude_ai_Notion__notion-create-pages` com
  `parent = { "type": "data_source_id", "data_source_id": "2e2cef37-3b56-80f4-a189-000b24e68729" }`
- **Schema:** `Name` (título) · `Date` (data) · `Tags` (multi_select)

## Campos e como perguntar

Regra WIBX (CLAUDE.md §1): **não infira campo obrigatório — pergunte.**

| Campo | Obrigatório? | Nota |
|---|---|---|
| **Título** | Sim | Vira o `Name`. Curto e claro (aparece no calendário). |
| **Data** | Sim | Dia; hora e intervalo são opcionais. Se disser "quinta", "dia 25", resolva para a data absoluta (peça o ano se ambíguo). |
| **Área** | Sim | Uma das tags de área. Se o usuário não disser, pergunte. |
| **Tipo** | Não (default `Afazer`) | Afazer, Reunião, Entrega, Marco ou evento genérico. |
| **Detalhes** | Não | Corpo. Se vazio, use o template do tipo. |

Se faltar Título, Data ou Área → **pare e pergunte** antes de criar.

## Tags disponíveis (multi_select — opções já cadastradas)

- **Áreas:** `DEV/TI` · `Marketing` · `CRIAÇÃO` · `CS/Suporte` · `Comercial` · `PMO` · `Financeiro` · `Admin`
- **Tipos:** `Afazer` · `Reunião` · `Entrega` · `Marco` · `Rotina` *(Rotina é só da rotina semanal — não use aqui)*

Monte `Tags` = `[<área>, <tipo>]`. Ex.: reunião de DEV/TI → `["DEV/TI", "Reunião"]`.

> **Gotcha:** `Tags` é multi_select — só aceita opções **já cadastradas**. Se precisar de uma
> tag que não está na lista acima (área ou tipo novo), ela **não pode ser criada no
> `notion-create-pages`** — daria erro `validation_error`. Antes, cadastre a opção via
> `mcp__claude_ai_Notion__notion-update-data-source` com
> `ALTER COLUMN "Tags" SET MULTI_SELECT(<lista COMPLETA: todas as opções atuais + a nova>)`
> (o `SET` casa por nome e preserva as existentes, mas você **precisa listar todas** ou as
> ausentes somem). Cadastrar opção nova = mudança de schema em database compartilhado →
> **peça OK do Pedro antes** (CLAUDE.md §6). Para as tags da lista acima, não precisa disso.

## Data e hora

- **Só dia:** `"date:Date:start": "2026-07-25"` (omita `is_datetime`, default dia inteiro).
- **Com hora:** `"date:Date:start": "2026-07-25T15:00:00-03:00"`, `"date:Date:is_datetime": 1`
  (fuso Brasil `-03:00`).
- **Intervalo/reunião com fim:** adicione `"date:Date:end": "...-03:00"` e `is_datetime: 1`.

## Corpo por tipo (use se o usuário não ditar o conteúdo)

**Afazer / Tarefa**
```
## Contexto
<de onde vem, por quê>

## Critério de pronto
- [ ] <o que precisa estar verdade pra fechar>
```

**Reunião** — sempre termina com o bloco **AI Meeting Notes** (grava a reunião direto do card).
```
## Participantes
- <quem>

## Pauta
- [ ] <tópico>

## Decisões / próximos passos
_(preencher na reunião)_

<meeting-notes>
	Reunião <mention-date start="YYYY-MM-DD"/>
</meeting-notes>
```

> **AI Meeting Notes (obrigatório em toda Reunião).** O bloco `<meeting-notes>` cria o card de
> gravação nativo do Notion — o time aperta "gravar/transcrever" direto na página. Regras de
> criação (spec Notion-flavored Markdown): indentação interna = **tab**; **omita** `<summary>` e
> `<transcript>` (dão erro na criação); só inclua `<notes>` se o usuário ditar notas. Use a **data
> da reunião** no `<mention-date>`. No JSON do `content`, o bloco vira:
> `\n\n<meeting-notes>\n\tReunião <mention-date start=\"YYYY-MM-DD\"/>\n</meeting-notes>`.
> Vale **só para Tipo = Reunião** — não colar em Afazer/Entrega/Marco.

**Entrega**
```
## O que entrega
<descrição> — para quem: <área/pessoa>

## Critério de pronto
- [ ] <definição de aceite>

## Link
<url do entregável, se houver>
```

**Marco**
```
## O que marca
<milestone>

## Depende de
- <bloqueios / pré-requisitos>
```

## Procedimento

1. **Reúna os campos.** Falta obrigatório → pergunte (não infira).
2. **Confirme em 1 linha** o que vai criar: `"<Título>" · <data/hora> · [<área>, <tipo>]`.
   (O pedido do usuário é a autorização para este write; a confirmação evita erro de data/área.)
3. **Se a tag necessária não existir**, cadastre-a primeiro (ver Gotcha) — com OK do Pedro.
4. **Crie** com `notion-create-pages` (parent = data source acima), `properties` =
   `{ "Name": <título>, "date:Date:start": <ISO>, [+ end/is_datetime], "Tags": [<área>, <tipo>] }`,
   `content` = corpo do tipo. **Se Tipo = Reunião, o corpo obrigatoriamente termina com o bloco
   `<meeting-notes>` (AI Meeting Notes) — ver template.**
5. **Devolva a URL** da página criada.

### Exemplo de payload

```json
{
  "parent": { "type": "data_source_id", "data_source_id": "2e2cef37-3b56-80f4-a189-000b24e68729" },
  "pages": [{
    "properties": {
      "Name": "Reunião de kickoff DEV/TI",
      "date:Date:start": "2026-07-28T10:00:00-03:00",
      "date:Date:is_datetime": 1,
      "Tags": ["DEV/TI", "Reunião"]
    },
    "content": "## Participantes\n- Caio, Ed, Coura\n\n## Pauta\n- [ ] Mapear ferramentas do depto\n\n## Decisões / próximos passos\n_(preencher na reunião)_\n\n<meeting-notes>\n\tReunião <mention-date start=\"2026-07-28\"/>\n</meeting-notes>"
  }]
}
```

## Verificação

- A resposta do `notion-create-pages` traz `id` + `url` e ecoa `properties` (confira data e tags).
- O item aparece na view de calendário da página WIBX LABS no dia certo.

## Rollback

- Item errado: deletar a página no Notion (deleção em database compartilhado = OK do Pedro, §6).
