---
name: cs-campaign-strategy
description: |
  Montagem de briefing e estratégia de campanha Wibx para o CS. Use sempre que alguém for
  planejar, desenhar, estruturar ou briefar uma campanha: "monta o briefing dessa campanha",
  "planeja a campanha do artista X", "qual mecânica usar", "estrutura a campanha do mês",
  "prepara o agendamento do dia 15", "faz a estratégia dessa ação". Constrói o Briefing de
  Estratégia no formato oficial, aplica o Checklist Mínimo Obrigatório (budget, alinhamento,
  objetivos, assets, duração), ajuda a escolher a mecânica respeitando os limites de
  caracteres de cada uma, e faz a triagem por tamanho (simples, média, grande) que define
  quem executa. Campanha sem briefing completo trava a cadeia inteira — Design, Tech e
  Marketing dependem do que sai daqui.
compatibility: Claude Desktop / claude.ai. Não escreve no Notion sozinha — produz o briefing pronto; o registro segue via wibx-demanda.
---

# CS Campaign Strategy — briefing e estratégia

O elo mais fraco da cadeia de campanha é o briefing incompleto: chega sem budget, sem
contexto, sem assets, e cada time a jusante para. Esta skill constrói o briefing completo de
primeira e decide o tamanho da demanda antes de qualquer execução.

## Briefing de Estratégia (formato oficial)

Toda campanha nasce com este bloco, sem exceção:

```
**Nome da campanha:**
**Data de publicação:**
**Objetivo:** <o que a campanha precisa alcançar, em 1–2 linhas mensuráveis>
**Marcas/influenciadores envolvidos:**
**Informações complementares:** <contexto do artista/marca, restrições, histórico>
```

## Checklist Mínimo Obrigatório (gate de entrada)

Antes de qualquer coisa virar demanda, os itens abaixo existem por escrito. Faltou um →
a demanda está **incompleta**: responda listando exatamente o que falta e não avance.

- [ ] **Budget total e por ação** (calcular com a skill `cs-budgeter`)
- [ ] **Reunião de alinhamento** feita (ou justificativa de por que não precisa)
- [ ] **Expectativas/objetivos** declarados
- [ ] **Músicas/projetos relevantes** (quando artista)
- [ ] **Ações sociais a evidenciar** (quando houver)
- [ ] **Assets** (links) ou plano de produção deles
- [ ] **Duração da campanha** definida

Princípios do gate: *"Nada se faz sem alinhamento"* e *"Simplificar, não burocratizar"* —
o checklist protege o time, não cria cerimônia.

## Escolha de mecânica

Mecânicas disponíveis: Indica+ · Play (music/vídeo) · Quiz · Circuito · Clique e Responda ·
Pesquisa · Shopping · Grupo VIP · posições de HOME (banners) · LP.

**Limites de caracteres (estouro = retrabalho no Business):**

| Mecânica | Limites |
|---|---|
| Indica+ / Play | título 100 · descrição 1000 |
| Clique e Responda | pergunta 75 · resposta 75 |
| Circuito | título 99 · regras 1000 |

<!-- TODO(time-CS): completar limites das demais mecânicas conforme a documentação oficial. -->

Toda copy proposta já sai contada dentro do limite. Recompensa: padrão 5 Wibx por engajamento
(exceção exige aprovação — ver `cs-budgeter`).

## Triagem por tamanho (define quem executa)

| Tamanho | Exemplos | Rota |
|---|---|---|
| **Simples** | repor campanha, ajustar banner, subir produto | direto com a dona da carteira |
| **Média** | campanha nova com criativo, ação de ranking | dona da carteira + apoio |
| **Grande** | novo app, mecânica inédita, urgência com impacto no cliente | força-tarefa do time |

Ser dona da carteira não significa executar tudo — significa ser responsável pela
**visibilidade**. A triagem existe para a demanda grande não afundar uma pessoa só.

## Cadência mensal (agendamento dia 15)

Todo dia 15 (ou próximo dia útil), cada dona de carteira agenda as campanhas do mês seguinte.
Cronograma modelo de uma rodada:

1. Alinhamento com o Design (semana do dia 15)
2. Seleção de conteúdos → até o fim do mês
3. Comunicação ao Marketing → até o fim do mês
4. Agendamento no Business → primeiros dias do mês
5. **Demanda para Tech aberta na véspera da ativação** (card antes, nunca depois)
6. Ativação

## Saída

Entregue: briefing completo no formato oficial + checklist com status item a item + mecânica
escolhida com copies dentro do limite + tamanho da triagem + cronograma com datas absolutas.
Registro no Notion segue via `wibx-demanda`; validação final pré-lançamento via
`cs-campaign-validation`.
