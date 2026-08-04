---
name: cs-budgeter
description: |
  Calculadora e validadora de budget de campanhas Wibx para o CS. Use sempre que alguém
  precisar calcular, conferir, validar ou solicitar budget/saldo de campanha: "calcula o
  budget dessa campanha", "quanto custa essa mecânica", "quanto cadastro no Business",
  "confere o saldo dessa carteira", "monta a solicitação de saldo", "esse budget aguenta
  quantos dias?", "valida esse orçamento". Aplica as regras da planilha oficial (valor do
  ponto fixo, taxa operacional de 3,5%, base de cálculo diferente por mecânica), valida
  contra campanhas semelhantes no histórico e entrega a linha pronta para o card de
  Solicitação de saldo. Campanha com budget insuficiente sai do ar no meio — esta skill
  existe para isso nunca mais acontecer.
compatibility: Claude Desktop / claude.ai com MCP Notion. Cotação Wibx do dia é input manual do usuário.
---

# CS Budgeter — cálculo e validação de budget

Budget mal calculado derruba campanha no ar, com fã reclamando em rede social e comunicação
de emergência fora do horário. O cálculo tem regras duras e bases diferentes por mecânica —
esta skill as aplica todas, sempre, e valida contra o histórico antes de aprovar.

## Constantes de negócio

| Regra | Valor |
|---|---|
| Valor do ponto | **R$ 0,0285 — fixo**; só diretoria/comercial altera |
| Cotação Wibx | **Manual**, preenchida no dia da publicação — **peça ao usuário**, não invente |
| Taxa operacional do Business | **3,5%**, descontada automaticamente |
| Recompensa padrão | **5 Wibx por engajamento** — alterar exige aprovação prévia |

> **Taxa de 3,5%:** para reservar o budget certo, o valor a **cadastrar** no Business é
> `budget_alvo / 1,035`. Ex.: budget 185.000 → cadastrar **178.744** (≈). Sempre mostre a
> conta; se a planilha oficial der um valor ligeiramente diferente (arredondamento), a
> planilha manda.

## Base de cálculo por mecânica (a pegadinha central)

| Mecânica | Base do débito no Business |
|---|---|
| **Indica+** | Recompensa **máxima em 24h × dias de campanha** |
| **Play** (music/vídeo) | **Total da campanha inteira** |

As duas usam bases diferentes — calcular Indica+ como Play (ou vice-versa) é o erro clássico.
Para as demais mecânicas (Quiz, Circuito, Clique e Responda, Shopping, Pesquisa), use
quantidade × recompensa por ação × limite por usuário, e confirme a base na planilha oficial.

<!-- TODO(time-CS): documentar aqui a base exata de débito das mecânicas além de Indica+ e
     Play, confirmada na planilha oficial. -->

## Procedimento

1. **Colete os inputs:** mecânica(s) · duração (dias) · recompensa por ação (padrão 5 Wibx) ·
   quantidade/limites por usuário · carteira/perfil de destino · **cotação Wibx do dia**
   (perguntar sempre).
2. **Calcule por mecânica:** pontos → valor em R$ (× 0,0285) → Wibx (÷ cotação) → base de
   débito conforme a tabela acima.
3. **Aplique a taxa:** valor a cadastrar = budget alvo ÷ 1,035. Mostre alvo e cadastro lado a
   lado.
4. **Confira o saldo da carteira** no destino antes de aprovar o número — budget maior que o
   saldo livre é bloqueio, não aviso. Saldo baixo (abaixo do limiar do time) entra como alerta.
   <!-- TODO(time-CS): confirmar limiar oficial de "saldo baixo" (relatórios usam 100k wbx). -->
5. **Valide contra o histórico:** busque no database de campanhas (`PLACEHOLDER_DB_CAMPANHAS`,
   campo de valor total) 2–3 campanhas semelhantes (mesma mecânica, perfil ou porte) e compare.
   Desvio grande do histórico sem justificativa = sinal amarelo, aponte antes de seguir.
   Histórico já queimou a mesma banda três vezes por budget insuficiente — é por isso que este
   passo não é opcional.
6. **Saída — linha pronta para o card de Solicitação de saldo:**

   | Nome do Projeto | Hash | Valor | Data limite |
   |---|---|---|---|
   | `<projeto>` | `<hash da carteira>` | `<valor a cadastrar>` | `<data>` |

7. **Aprovação:** validação prévia com os aprovadores designados do time é obrigatória antes
   de subir (quem são está nas instruções privadas do projeto — `PLACEHOLDER_APROVADORES_BUDGET`).
   Recompensa fora do padrão de 5 Wibx exige aprovação explícita de exceção.

## Verificação

- A conta fecha nos dois sentidos: valor cadastrado × 1,035 ≈ budget alvo.
- Base de débito usada bate com a mecânica (Indica+ = 24h × dias; Play = total).
- Saldo da carteira ≥ valor a cadastrar.
- Comparação com histórico registrada na resposta (quais campanhas, quais valores).

## Rollback

Solicitação com valor errado já enviada: corrigir no próprio card com a conta certa e avisar
os aprovadores — nunca abrir uma segunda solicitação paralela para o mesmo projeto.

## Limites

- Cotação e saldo em tempo real vivem no dashboard operacional (Grafana) — fora do alcance do
  Claude Desktop. **Peça os números ao usuário** e registre-os na resposta com data/hora.
- Esta skill calcula e valida; quem cadastra no Business é humano.
