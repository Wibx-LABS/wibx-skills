---
name: cs-reporter
description: |
  Gerador dos relatórios do CS Wibx — o diário de tasks e o mensal de performance. Use
  sempre que alguém precisar montar, gerar ou atualizar relatório: "monta o relatório
  diário", "gera o report de hoje", "relatório de tasks", "fecha o relatório do dia",
  "relatório mensal de performance", "report da carteira do mês", "prepara o relatório do
  dia 15". Modo diário: puxa o kanban de demandas com Tech via MCP Notion, gera o template
  canônico (alertas de Nível 1 não atendidas, status por cor, indicadores do dia), cria a
  página no Notion e entrega o texto pronto para colar no grupo de follow-up. Modo mensal:
  relatório de performance por carteira no formato que alimenta o sistema de análise.
  Relatório é o maior consumidor de tempo do CS — mais da metade das demandas registradas —
  e esta skill transforma uma montagem manual em minutos de conferência.
compatibility: Claude Desktop / claude.ai com MCP Notion. Números de engajamento/saldo do dashboard operacional entram como input manual.
---

# CS Reporter — relatório diário e mensal

Mais da metade das demandas registradas do CS são relatório. O formato já é canônico; o que
custa caro é montar na mão todo dia. Esta skill puxa os dados, monta no formato exato e deixa
o humano só conferir e colar.

## Config (IDs privados)

Alvos reais via Project Instructions privadas (ver `references/config.md`):
`PLACEHOLDER_KANBAN_TECH` · `PLACEHOLDER_DB_DEMANDAS` · `PLACEHOLDER_DB_CAMPANHAS`.
Placeholder ausente → pare e avise.

## Modo diário — Relatório de tasks

1. **Puxe o kanban** de demandas com Tech (`PLACEHOLDER_KANBAN_TECH`) via MCP: status, nível
   de prioridade, datas de abertura/fechamento.
2. **Monte o template canônico:**

```
Relatório de tasks | [dd/mm/aa] | [NOME]

🛑 ALERTA — Demandas Nível 1 não atendidas
- <demanda> · o que falta: <...> · impacto: <...> · motivo do atraso: <...>
(nenhuma → "Sem pendências Nível 1 hoje." — N1 de ontem não fechada entra como Urgência máxima)

🔄 Status geral
🟢 <finalizadas/andando bem> · 🟡 <em andamento com atenção> · 🔴 <bloqueadas/atrasadas>

📊 Indicadores do dia
- Demandas ativas com Tech: <n>
- Abertas hoje: <n> · Encerradas hoje: <n>
- Pendências críticas: <n>
```

3. **Crie a página** `Relatório de tasks | [dd/mm/aa] | [NOME]` no destino
   (`PLACEHOLDER_DB_DEMANDAS`), tipo Relatório.
4. **Entregue também o texto puro** (sem markdown de Notion) pronto para colar no grupo de
   follow-up do WhatsApp.

## Modo mensal — Relatório de performance (dia 15)

Por carteira, cobrindo o mês anterior:

```
Relatório de performance | [mês/ano] | Carteira [NOME]

## Campanhas do mês
| Campanha | Mecânica | Status | Budget | WBX distribuídos |

## Números da carteira
- Campanhas ativas / concluídas / canceladas
- WBX distribuídos no total
- Base de usuários · Engajados · Convertidos
- Presença de comunicação (campanhas com divulgação vs sem)

## Alertas
- Perfis com saldo baixo (listar com saldo exato)
- Campanhas que encerraram por budget esgotado
- Reagendamentos não concluídos por falta de saldo

## Leitura do mês
<2–3 linhas: o que funcionou, o que repetir, o que evitar>
```

- Campanhas e budgets saem do database oficial (`PLACEHOLDER_DB_CAMPANHAS`) via MCP.
- Engajamento e saldos vivem no dashboard operacional (fora do alcance do Desktop): **peça os
  números ao usuário** e registre a data/hora da extração no relatório.
- A estrutura de números (base, engajados, convertidos, WBX, comunicação) é a que o sistema
  de análise do time consome — manter os nomes dos campos estáveis.

## Verificação

- Os totais do relatório batem com a contagem da fonte (conferir 2–3 números por amostragem
  contra o kanban/database antes de publicar).
- A página criada é legível e está no padrão de título exato (`Relatório de tasks | dd/mm/aa
  | NOME`) — o histórico já se perdeu uma vez porque o padrão de título mudou três vezes.
- Números vindos de dashboard trazem data/hora da extração.

## Rollback

Relatório com número errado já publicado: corrigir na própria página com nota de correção
datada (nunca apagar o valor anterior) e reenviar o texto corrigido no grupo.
