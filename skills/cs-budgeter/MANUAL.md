# Manual: CS Budgeter Skill

---

#### 🇺🇸 English
**What it does:**
Calculates and validates Wibx campaign budgets for the CS team, applying the official spreadsheet rules — fixed point value (R$ 0.0285), the Business platform's automatic 3.5% operational fee, and the different debit bases per mechanic (Indica+ charges max 24h reward × campaign days; Play charges the whole campaign total). Outputs the ready-to-paste line for the balance-request card.

**Key Features:**
- **The 3.5% Fee Done Right:** Registers `target / 1.035` so the reserved budget lands where intended, showing the math both ways.
- **Per-Mechanic Debit Base:** Encodes the classic trap — Indica+ and Play are billed on different bases; mixing them up is how campaigns die mid-air.
- **History Validation, Mandatory:** Compares against 2–3 similar past campaigns from the campaigns database before approving a number. The same artist got underfunded three times for lack of this step.
- **Balance Check as a Blocker:** Budget above the wallet's free balance blocks; low balance raises an alert.
- **Approval Rules:** Prior validation with the designated approvers; 5-Wibx-per-engagement default, exceptions need explicit sign-off.
- **Honest About Limits:** Live quotes and balances come from the ops dashboard the Desktop can't reach — the skill asks the user for today's numbers and records them with a timestamp.

---

#### 🇧🇷 Português
**O que faz:**
Calcula e valida budget de campanhas Wibx para o time de CS, aplicando as regras da planilha oficial — valor do ponto fixo (R$ 0,0285), taxa operacional automática de 3,5% do Business, e as bases de débito diferentes por mecânica (Indica+ cobra recompensa máxima em 24h × dias; Play cobra o total da campanha). Entrega a linha pronta para o card de Solicitação de saldo.

**Principais Recursos:**
- **Taxa de 3,5% Sem Erro:** Cadastra `alvo ÷ 1,035` para a reserva cair no valor certo, mostrando a conta nos dois sentidos.
- **Base de Débito por Mecânica:** Codifica a pegadinha clássica — Indica+ e Play são cobradas em bases diferentes; confundir as duas é como campanha morre no meio.
- **Validação Histórica Obrigatória:** Compara com 2–3 campanhas semelhantes do database antes de aprovar um número. A mesma banda já saiu subfinanciada três vezes por falta deste passo.
- **Saldo Como Bloqueio:** Budget acima do saldo livre da carteira bloqueia; saldo baixo vira alerta.
- **Regras de Aprovação:** Validação prévia com os aprovadores designados; padrão de 5 Wibx por engajamento, exceção exige aprovação explícita.
- **Honesta Sobre Limites:** Cotação e saldo em tempo real vivem no dashboard operacional que o Desktop não alcança — a skill pede os números do dia ao usuário e os registra com data/hora.
