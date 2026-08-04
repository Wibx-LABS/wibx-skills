# Manual: CS Notion Reporting Skill

---

#### 🇺🇸 English
**What it does:**
Routes every Wibx CS/Support demand to the right Notion destination — Tech request form, Design/Creative board, Support tracking, Product reports or the CS demands database — with the full required payload, the official N1/N2/N3 priority classification and the canonical bug format. A demand without a card has no tracking and no SLA; this skill makes sure the card exists, in the right place, complete on the first try.

**Key Features:**
- **Destination Decision Tree:** One table decides where each demand goes, ending the "a bug has 4 possible destinations" problem. Never opens the same demand twice.
- **Priority by Rule, Not Feel:** Broken link is always N1; POC work is N1; internal campaign homes are N2; internal-only bugs are N3. Unfinished N1 escalates to "maximum urgency" next day.
- **Canonical Bug Format:** Title / Where / Current behavior / Expected behavior / Impact / Evidence / Payload. Payload is filled even where the form makes it optional — a bug without payload is a guaranteed round-trip.
- **Design SLA Table Built In:** Publication dates get set against the agreed Design SLAs (full home 3 business days, monthly pack 10–12, POC campaign 3 weeks), so CS never promises the impossible.
- **Private IDs Stay Private:** The repo is public; every Notion target is a `PLACEHOLDER_*` resolved from the project's private instructions. Missing placeholder → the skill stops and asks instead of guessing.
- **Archive, Never Delete:** Wrong card gets archived with a pointer from its replacement.

---

#### 🇧🇷 Português
**O que faz:**
Roteia toda demanda do CS/Suporte Wibx para o destino certo no Notion — formulário Tech, board de Criação/Design, acompanhamento de Suporte, reporte de Produto ou database de demandas do CS — com o payload obrigatório completo, a classificação oficial de prioridade N1/N2/N3 e o formato canônico de bug. Demanda sem card não tem tracking nem SLA; esta skill garante que o card exista, no lugar certo, completo de primeira.

**Principais Recursos:**
- **Árvore de Decisão de Destino:** Uma tabela decide para onde cada demanda vai, acabando com o problema do "bug tem 4 destinos possíveis". Nunca abre a mesma demanda em dois lugares.
- **Prioridade por Regra, Não por Feeling:** Link quebrado é sempre N1; trabalho de POC é N1; home de campanha interna é N2; bug só interno é N3. N1 não finalizado escala para "Urgência máxima" no dia seguinte.
- **Formato Canônico de Bug:** Título / Onde / Comportamento atual / Comportamento esperado / Impacto / Evidência / Payload. O payload é preenchido mesmo onde o formulário o deixa opcional — bug sem payload é ida-e-volta garantida.
- **Tabela de SLA do Design Embutida:** Datas de publicação são definidas contra os SLAs acordados (home completa 3 dias úteis, pacote mensal 10–12, campanha POC 3 semanas), então o CS nunca promete o impossível.
- **IDs Privados Ficam Privados:** O repo é público; todo alvo Notion é um `PLACEHOLDER_*` resolvido pelas instruções privadas do projeto. Placeholder faltando → a skill para e pergunta em vez de adivinhar.
- **Arquivar, Nunca Deletar:** Card errado é arquivado com ponteiro a partir do substituto.
