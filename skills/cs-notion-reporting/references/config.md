# Config: alvos Notion do CS (placeholders)

Esta skill vive num repo **público**. Nenhum ID real de Notion aparece aqui. Cada placeholder
abaixo é definido nas **Project Instructions privadas** do projeto Claude do time de CS
(mantidas no repo privado de setup). A skill lê o valor de lá em tempo de uso.

| Placeholder | O que aponta | Tipo |
|---|---|---|
| `PLACEHOLDER_FORM_TECH` | Formulário de solicitações CS/Comercial para Tech | form view + data source |
| `PLACEHOLDER_KANBAN_TECH` | Kanban de acompanhamento dos requerimentos Tech | data source |
| `PLACEHOLDER_BOARD_DESIGN` | Board de tarefas do Design/Criação | data source |
| `PLACEHOLDER_DB_SUPORTE` | Acompanhamento de problemas de suporte (pedidos/resgates) | data source |
| `PLACEHOLDER_DB_PRODUTO` | Abertura de chamados CS x Produto | data source |
| `PLACEHOLDER_DB_DEMANDAS` | Database de demandas macro do CS | data source |
| `PLACEHOLDER_DB_CAMPANHAS` | Database oficial de campanhas do CS | data source |

## Formato esperado nas Project Instructions privadas

```
PLACEHOLDER_FORM_TECH = collection://<uuid>  (url: https://app.notion.com/...)
PLACEHOLDER_KANBAN_TECH = collection://<uuid>
...
```

## Fallback

1. Placeholder ausente nas instruções do projeto: **pare e avise o usuário** — peça para
   adicionar o mapa de IDs do setup privado ao projeto. Não crie card em destino adivinhado.
2. `notion-create-pages` falhou (permissão/ID inválido): reporte o erro literal e o destino
   tentado; não tente destino alternativo sem confirmar.
