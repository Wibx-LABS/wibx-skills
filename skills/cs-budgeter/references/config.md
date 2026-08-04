# Config: alvos Notion do cs-budgeter (placeholders)

Repo público — nenhum ID real aqui. Placeholders resolvidos pelas Project Instructions
privadas do projeto do time de CS.

| Placeholder | O que aponta |
|---|---|
| `PLACEHOLDER_DB_CAMPANHAS` | Database oficial de campanhas do CS (histórico com campo de valor total) |
| `PLACEHOLDER_DB_TAREFAS` | Board operacional onde vive o card recorrente de Solicitação de saldo |
| `PLACEHOLDER_APROVADORES_BUDGET` | Quem valida budget antes de subir (nomes nas instruções privadas) |

## Fallback

1. Placeholder ausente: pare e peça o mapa de IDs privado ao usuário.
2. Histórico sem campanhas comparáveis (campo de valor vazio na maioria dos registros é
   realidade conhecida): diga explicitamente que a validação histórica ficou fraca e com
   quantos pontos de comparação; não finja robustez.
