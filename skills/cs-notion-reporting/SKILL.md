---
name: cs-notion-reporting
description: |
  Roteador de demandas do CS/Suporte Wibx no Notion. Use sempre que alguém do CS precisar
  reportar, abrir, registrar ou encaminhar qualquer demanda — bug, home, campanha, arte,
  loja/perfil, problema de pedido — para Tech/TI, Design/Criação, Produto ou para o próprio
  CS: "abre um card pra TI", "reporta esse bug", "manda essa demanda pro design", "registra
  essa solicitação", "onde eu abro isso?", "formata esse chamado", "sobe essa demanda no
  Notion". Decide o destino certo (formulário Tech, board de Criação, acompanhamento de
  Suporte, reporte de Produto ou database de demandas), monta o payload com todos os campos
  obrigatórios, classifica a prioridade N1/N2/N3 pela regra oficial e aplica o formato
  canônico de bug com evidência e payload. Os IDs reais das databases vêm das instruções
  privadas do projeto (não vivem nesta skill).
compatibility: Claude Desktop / claude.ai com MCP Notion conectado. IDs reais via Project Instructions privadas.
---

# CS Notion Reporting — roteador de demandas

Uma demanda sem card não existe: não tem tracking, não tem SLA, não tem correção quando algo
quebra. Esta skill garante que toda demanda do CS vire o registro certo, no lugar certo, com
os campos certos — na primeira tentativa, sem ida-e-volta.

## Config (IDs privados)

Os alvos reais (databases, formulários, data sources) **não estão nesta skill** — o repo é
público. Eles vêm das **Project Instructions privadas** do seu projeto no Claude, que definem
cada `PLACEHOLDER_*` listado em `references/config.md`. Se um placeholder não estiver definido
nas instruções do projeto, **pare e avise** — não adivinhe destino via busca.

## Passo 1 — Decidir o destino

| A demanda é... | Destino | Placeholder |
|---|---|---|
| Bug de app/Business, home, encerramento de campanha, config de enterprise, dashboard, nova campanha/produto (execução técnica) | **Formulário Tech** | `PLACEHOLDER_FORM_TECH` |
| Arte: home, banner, template de campanha, LP, asset | **Board de Criação/Design** | `PLACEHOLDER_BOARD_DESIGN` |
| Problema de pedido/resgate de usuário final (não recebeu, entrega, pedido duplicado) | **Acompanhamento de problemas Suporte** | `PLACEHOLDER_DB_SUPORTE` |
| Bug/melhoria de produto (comportamento do app como produto, não incidente operacional) | **CS x Produto** | `PLACEHOLDER_DB_PRODUTO` |
| Demanda macro do próprio CS (relatório, campanha mensal, análise, regulamento) | **Database de Demandas do CS** | `PLACEHOLDER_DB_DEMANDAS` |

Em dúvida entre Tech e Produto: incidente que afeta operação/usuário **agora** → Tech;
sugestão/comportamento a mudar → Produto. Nunca abra a mesma demanda em dois lugares.

## Passo 2 — Classificar a prioridade (regra oficial N1/N2/N3)

| Nível | Gatilhos |
|---|---|
| **N1 Crítico** | Link quebrado (**sempre N1**) · bug reportado por parceiro/cliente externo · bug de pagamento · home de POC · encerramento de campanha de POC |
| **N2 Alto** | Home de campanha interna · criação de perfil/loja para POC ou stakeholder · encerramento de campanha/produto interno |
| **N3 Médio** | Falha interna sem urgência · criação de perfil/loja padrão das marcas |

Regra de escalonamento: **N1 não finalizado no dia vira "Urgência máxima" na abertura do dia
seguinte** — cite isso no card quando reabrir.

## Passo 3 — Montar o payload por destino

### Tech (formulário)

Todos os campos do formulário são obrigatórios exceto o payload do bug. Reúna **antes** de
submeter: título · descrição · período (de/até) · comunidade/whitelabel · tipo (bug ou novo
requerimento) · tipo de requerimento · evidência do bug (vídeo ou print — obrigatório) · IDs
de perfil/loja/campanha envolvidos · JSON de home quando for home.

> **Regra de ouro: preencha o payload do bug mesmo sendo o único campo opcional.** Bug sem
> payload é ida-e-volta garantida ("funcionou comigo"). Se não conseguir capturar o payload,
> grave um vídeo da tela reproduzindo o erro — e diga no card que o payload não foi capturável.

### Formato canônico de bug (usar na descrição, em qualquer destino)

```
**Título:** <resumo em 1 linha>
**Onde acontece:** <app/Business, tela, perfil/loja, ID>
**Comportamento atual:** <o que acontece>
**Comportamento esperado:** <o que deveria acontecer>
**Impacto:** <quem é afetado e desde quando; cliente externo? pagamento?>
**Evidência:** <link do vídeo/print>
**Payload:** <payload capturado, ou "não capturável — vídeo anexado">
```

### Design/Criação (payload obrigatório)

Por home/arte: artista/perfil · conteúdo ou campanha prioritária · link/direcionamento ·
posições da home que serão alteradas · prioridade · **data necessária de publicação**.

Expectativa de prazo (SLAs acordados com o Design — use para definir a data e não prometer
impossível ao cliente):

| Entrega | Prazo |
|---|---|
| Home completa | 3 dias úteis |
| Pacote de homes (até 27) | 9 dias úteis |
| Template de campanha | 1 dia útil |
| Pacote de templates (até 7) | 3 dias úteis |
| Pacote mensal completo (7 templates + 27 homes) | 10–12 dias úteis |
| Home sazonal | 5 dias úteis |
| Banner sazonal personalizado | 2 dias úteis a cada 5 banners |
| Campanha completa POC/evento | 3 semanas |
| LP | 3 dias úteis |

Briefing incompleto atrasa a cadeia inteira — **valide a completude antes de enviar**
(é responsabilidade do CS, não do Design).

### Suporte (problema de pedido)

Título no padrão `[usuário] | [resumo do problema]` · tipo (verificar pedido, problema com
entrega, pedido duplicado, bug, não recebeu) · login do usuário · número do pedido · data da
compra · anexos.

### Database de Demandas (macro)

Demanda · tipo de demanda · prioridade · período (início/fim) · **prazo final** · responsável ·
comentários pertinentes. Datas de início, fim e prazo **sempre** — é o que torna a demanda
mensurável.

## Passo 4 — Criar e verificar

1. Confirme em 1 linha com o usuário: destino · título · prioridade · prazo.
2. Crie via MCP Notion (`notion-create-pages` no data source do destino, conforme as
   instruções privadas do projeto).
3. **Verificação:** releia a página criada; confira que todo campo obrigatório do destino está
   preenchido e que a prioridade bate com a regra N1/N2/N3. Devolva a URL do card.
4. Card criado **antes** de qualquer execução começar — nunca depois.

## Rollback

Card errado: **arquivar, nunca deletar** (a lixeira é recuperável; deleção em database
compartilhado precisa de aprovação do responsável pelo workspace). Registrar no card
substituto o link do arquivado.

<!-- TODO(time-CS): confirmar qual dos dois databases de requerimentos Tech é o canônico
     (formulário de entrada vs kanban triado) e aposentar o outro. Hoje existem campos
     duplicados em inglês e português no mesmo fluxo. -->
