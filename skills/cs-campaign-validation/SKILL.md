---
name: cs-campaign-validation
description: |
  Gate de validação pré-lançamento de campanha Wibx para o CS. Use sempre que uma campanha
  estiver prestes a subir, ser agendada ou ativada: "valida essa campanha antes de subir",
  "confere se está tudo pronto", "pode ativar?", "checklist de lançamento", "revisa antes de
  agendar no Business", "essa campanha está ok?". Roda o checklist bloqueante: budget
  calculado e saldo conferido, card de Tech aberto ANTES da execução, briefing completo
  validado antes do Design, aprovações feitas, recompensa no padrão, assets anexados, datas
  definidas. Campanha que falha em qualquer item fica BLOQUEADA com a lista exata do que
  falta. Existe porque uma campanha já saiu do ar por budget esgotado, sem card para rastrear
  e com comunicação de emergência fora do horário — nenhum item deste checklist é decorativo.
compatibility: Claude Desktop / claude.ai. Lê Notion via MCP para conferir cards; não ativa nada — o go/no-go é humano.
---

# CS Campaign Validation — gate pré-lançamento

Cada item deste checklist é uma cicatriz: campanha fora do ar por budget esgotado, crise sem
card para rastrear, briefing incompleto travando o Design. O gate transforma as lições em
bloqueio automático — barato de passar quando o trabalho foi feito, impossível de furar
quando não foi.

## O checklist bloqueante

Rode item a item. **Qualquer item reprovado → status BLOQUEADA**, com a lista exata do que
falta. Sem exceção por urgência — urgência foi como as crises começaram.

| # | Item | Critério de aprovação |
|---|---|---|
| 1 | **Budget calculado** | Conta feita via `cs-budgeter`: base de débito certa por mecânica, taxa de 3,5% aplicada, valor a cadastrar explícito |
| 2 | **Saldo conferido** | Saldo livre da carteira ≥ valor a cadastrar, com número e data/hora de quando foi conferido |
| 3 | **Validação histórica** | Budget comparado com 2–3 campanhas semelhantes; desvio grande justificado por escrito |
| 4 | **Card de Tech aberto ANTES** | Demanda registrada no destino oficial (via `cs-notion-reporting`) antes de qualquer execução — a falta do card foi a causa-raiz de crise real |
| 5 | **Briefing completo** | Checklist Mínimo Obrigatório da `cs-campaign-strategy` 100% verde; validar completude é responsabilidade do CS antes de enviar ao Design |
| 6 | **Aprovações feitas** | Validação prévia com os aprovadores designados (`PLACEHOLDER_APROVADORES_BUDGET` nas instruções privadas) registrada |
| 7 | **Recompensa no padrão** | 5 Wibx por engajamento, ou aprovação de exceção por escrito |
| 8 | **Assets prontos** | Artes entregues e anexadas (prazo do Design respeitado — ver tabela de SLA na `cs-notion-reporting`) |
| 9 | **Datas definidas** | Data de publicação, duração e data de encerramento explícitas; quem monitora o encerramento nomeado |

## Formato da resposta

**Aprovada:**

```
✅ CAMPANHA LIBERADA — <nome>
9/9 itens verdes. Valor a cadastrar: <valor> · Ativação: <data> · Encerramento: <data> (monitor: <quem>)
```

**Bloqueada (resposta padrão para demanda incompleta):**

```
🚫 CAMPANHA BLOQUEADA — <nome>
Falta:
- [ ] <item exato + o que precisa ser entregue para destravar>
- [ ] ...
Destravar: reenviar com os itens acima. Nada se faz sem alinhamento; o gate simplifica, não burocratiza.
```

## Verificação

- Cada item tem evidência apontada (link do card, número do saldo, nome de quem aprovou) —
  "confio que está ok" não é evidência.
- O resultado (liberada/bloqueada + lista) fica registrado no card da campanha no Notion.

## Rollback

Campanha liberada por engano: registrar a reprovação no mesmo card (nunca apagar o parecer
anterior) e avisar quem for ativar. Se já ativou, o incidente segue via `cs-notion-reporting`
como N1/N2 conforme o impacto.
