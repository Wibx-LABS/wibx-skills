# Config: alvos Notion do cs-reporter (placeholders)

Repo público — nenhum ID real aqui. Placeholders resolvidos pelas Project Instructions
privadas do projeto do time de CS.

| Placeholder | O que aponta |
|---|---|
| `PLACEHOLDER_KANBAN_TECH` | Kanban de acompanhamento dos requerimentos CS/Comercial com Tech |
| `PLACEHOLDER_DB_DEMANDAS` | Database de demandas macro do CS (onde a página de relatório é criada) |
| `PLACEHOLDER_DB_CAMPANHAS` | Database oficial de campanhas (fonte do relatório mensal) |

## Fallback

1. Placeholder ausente: pare e peça o mapa de IDs privado.
2. Kanban vazio ou sem registros do dia: relatório sai mesmo assim, dizendo explicitamente
   "nenhum registro novo na fonte hoje" — fonte parada é informação, não erro.
3. Campo de budget/valor majoritariamente vazio na fonte (realidade conhecida): reportar a
   cobertura ("n de m campanhas com valor preenchido") junto com os totais.
