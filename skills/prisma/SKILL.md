---
name: prisma
description: >-
  Construir personas sintéticas defensáveis e simulações multi-agente seguindo o método PRISMA (Evidence → Job → Persona → Cena). Use sempre que o usuário pedir buyer persona, ICP, simulação de negociação, dress rehearsal de pitch, painel sintético, entrevista simulada, customer interview rehearsal, ou qualquer construção de agente sintético a partir de dados reais. Aplica os 4 axiomas: supremacia da evidência, defensável melhor que interessante, hierarquia de verdade, gates anti-alucinação. Dispara também em "construa uma persona", "monte uma simulação", "ensaie meu pitch", "treine essa entrevista", "modele esse comprador".
---

# Skill: PRISMA

Você está executando o método PRISMA: construir agentes sintéticos defensáveis a partir de evidência observável. PRISMA tem dois pipelines complementares:

1. **Pipeline single-persona** (`Evidence → Job → Persona`) — uma persona defensável.
2. **Pipeline multi-agente** (8 arquivos modulares) — cena com múltiplas personas + decisão estruturada.

---

## Axiomas não-negociáveis

Você não pode violar nenhum destes:

1. **Supremacia da evidência** — nada pode aparecer na persona/cena se não estiver suportado por evidência rastreável.
2. **Defensável > interessante** — uma persona boa é a mais defensável, não a mais saborosa.
3. **Hierarquia de verdade** — nada sobe se não existir abaixo. `Evidence Pack → Job JSON → Persona → Cena`.
4. **Gates anti-alucinação** — cobertura mínima, frases proibidas, bloqueio automático quando evidência é fraca.

---

## Frases proibidas (substitua antes de gerar)

- ❌ "provavelmente", "tende a", "parece que", "em geral", "imagino que"
- ✅ "com base nas evidências disponíveis…", "os dados indicam…", "não há evidência suficiente para…"

---

## Quando disparar esta skill

- "Construa uma persona para [nome/segmento]"
- "Monte uma simulação de negociação / board / entrevista"
- "Ensaie meu pitch / minha conversa difícil"
- "Crie um painel sintético de [tipo]"
- "Treine essa entrevista / esse calls"
- "Modele esse comprador / esse decisor"
- "Faça um dress rehearsal de [cenário]"

---

## Decisão inicial: qual pipeline?

Pergunte (em 1 frase):

> "Você quer (a) uma persona defensável a partir de dados reais, ou (b) uma simulação multi-agente com decisão estruturada?"

- (a) → use **Pipeline single-persona** (assets/01_pipeline_synthetic/).
- (b) → use **Pipeline multi-agente** (assets/02_pipeline_simulation/). Geralmente requer (a) primeiro para cada persona da cena.

---

## Pipeline single-persona — execução

### Etapa 1: Evidence Pack

Pergunte ao usuário:

- Quem é o alvo (nome, função, empresa, contexto)?
- Onde tem evidência pública (LinkedIn, Twitter/X, Medium, podcast, site, reviews)?
- Tem material privado (entrevistas internas, emails, transcrições) com consentimento de uso?

**Gate 1 — coverage mínima:**
- ≥10 posts
- ≥10 comentários feitos pela pessoa
- ≥3.000 caracteres de corpus
- `identity_snapshot` preenchido

Se não atinge → **pare**. Diga quanto falta. Não force.

Use `assets/01_pipeline_synthetic/templates/evidence_pack.template.json` para estruturar.

Se o usuário não tem evidência real mas quer prosseguir:
- Marque `status: "synthetic_no_anchor"` + `disclosure` explícita.
- Continue o pipeline normalmente. A defensabilidade muda de tipo.

### Etapa 2: Sinais (Evidence → Signals)

Para cada item textual:
- Tópicos recorrentes (≥3 ocorrências) com `source_ids`.
- Problemas explícitos com `source_id`.
- Soluções defendidas com `source_id`.
- Critérios de decisão mencionados com `source_id`.
- Ideias rejeitadas com `source_id`.
- Linguagem: termos frequentes, tom, padrões de escrita, frases notáveis.

Não inferir motivação, intenção, personalidade.

### Etapa 3: Job JSON

Gere conforme `assets/01_pipeline_synthetic/schemas/job.schema.json`.

**Gate 2 — decision signals:**
- ≥3 critérios de decisão explícitos
- ≥2 rejeições claras
- ≥3 problemas recorrentes

Cada campo crítico precisa de `evidence_refs`. Contradições → registre em `contradictions` com `prevalence_pct`, não silencie.

Se falta evidência → `insufficient_evidence_fields` + `confidence: low`.

`validation.ready_for_persona: true` apenas se todos os gates passam.

### Etapa 4: Persona

Gere conforme `assets/01_pipeline_synthetic/schemas/persona.schema.json`.

**Regra dura:** a Persona pode reformular, simplificar, narrar — **não pode** adicionar fatos, desejos, medos ausentes do Job JSON.

Cada campo precisa estar listado em `traceability.fields_derived_from_job` ou em `traceability.fields_marked_decorative` (apenas `meta_attributes`).

Não atribuir MBTI, Enneagrama, diagnósticos clínicos sem dados declarados pelo próprio indivíduo.

Entregue ao usuário os 3 arquivos: `evidence_pack.json`, `job.json`, `persona.json`.

---

## Pipeline multi-agente — execução

### Pré-requisito

Para cada persona da cena: idealmente vinda do pipeline single-persona. Se não, declare claramente como `synthetic_no_anchor`.

### Os 8 arquivos

Use os schemas e templates em `assets/02_pipeline_simulation/`. Construa nesta ordem:

1. **Story Board** (`story_board.md`) — 3 ATC (Atores, Tensão, Contexto). Inclua bomba relógio, gap explícito, custo de não-acordo.
2. **Personas** (`persona_<N>.json`) — uma por participante.
3. **Speaking Balance** (`speaking_balance.json`) — pesos, fases, ativação por tópico, fairness.
4. **Response Structure** (`response_structure.json`) — persona block + status block + next_move block; ordem; machine summary.
5. **Group Dynamics** (`group_dynamics.json`) — interação, coalizões, ping-pong, repair moves.
6. **Behavioral Guidelines** (`behavioral_guidelines.json`) — global do/dont + por persona + adaptation + evidence_norms + overwhelm response.
7. **Decision Logic** (`decision_logic.json`) — outcomes (≥2), veto rules, min_turns_before_decision, fallback, evaluation_dimensions, min_scores.
8. **Master Prompt** (`master_prompt.md`) — prompt único que monta tudo.

### Verificação cruzada antes de entregar

- Cada `persona_id` referenciado existe em alguma `persona_<N>.json`?
- `min_scores_for_approval` referencia nomes de `evaluation_dimensions` existentes?
- `fallback_if_no_consensus.after_turn` < `max_turns`?
- Outcomes cobrem os finais plausíveis do Story Board?
- Behavioral por persona não contradiz a persona declarada?

### Entrega

Entregue ao usuário os 8 arquivos + indicação de destino de deploy (Google AI Studio, Claude Console, ChatGPT GPT — ver `assets/02_pipeline_simulation/deploy/`).

---

## Bloqueio automático

Pare e peça input do humano antes de gerar quando:

- Usuário pede persona sem evidência rastreável e não quer declarar `synthetic_no_anchor`.
- Persona é de figura pública identificável sem consentimento documentado.
- Cenário envolve decisão real (financeira, jurídica, médica) onde output pode ser tomado como recomendação.
- Usuário pede para "inventar persona do zero" sem qualquer ancoragem — explique que PRISMA não faz isso; ofereça os caminhos honestos (coletar evidência, declarar sintético, usar template como ponto de partida estilístico).

---

## Compliance — vocabulário WIBX LABS (quando aplicável)

Se o conteúdo é institucional Wibx (BORA, MINU, AMOS, ACSOS, Music Lovers, Gate0, WomanX, Amplyfiq, Uau CAIXA), aplique:

- "valor demonstrado" → "transparência operacional"
- "investimentos ESG" → "iniciativas ESG"
- "retorno" → "resultado operacional"

**Nunca** descreva WBX como investimento/valorização/ROI/yield/ativo especulativo.

Não se aplica a personas/simulações genéricas sem ligação ao ecossistema Wibx.

---

## Saída esperada para o usuário

Ao concluir qualquer execução, entregue:

1. Os arquivos gerados (anexos JSON/MD).
2. Um sumário em prosa de ≤200 palavras explicando o que foi construído + quais campos foram marcados `insufficient_evidence` (se houver).
3. Próximo passo recomendado (qual playbook em `assets/04_playbooks/` aplicar, ou qual deploy seguir).

---

## A regra final

> **Uma persona boa não é a mais interessante. É a mais defensável.**
