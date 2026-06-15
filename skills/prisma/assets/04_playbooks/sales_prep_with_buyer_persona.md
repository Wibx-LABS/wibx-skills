# Playbook: Sales prep com buyer persona defensável

> **Caso de uso:** Você tem uma reunião importante com um buyer (decisor, gatekeeper, champion) em ≤7 dias. Precisa entrar preparado para a conversa real, não para a "típica conversa de buyer do setor X".

> **Tempo total:** 4-8 horas de trabalho do operador (a depender de quanta evidência o buyer deixa pública). Pode ser delegado a IA com supervisão.

> **Saída esperada:** `persona.json` defensável + script de 5-7 perguntas calibradas + lista de 3 objeções esperadas com respostas pré-preparadas.

---

## Pré-requisitos

- Nome + cargo + empresa do buyer.
- Acesso a perfil LinkedIn público.
- Idealmente: 1 hora de tempo do AE/SDR que já interagiu com o buyer (para sinal qualitativo).

---

## Passos

### 1. Captura de evidência (30-60 min)

Abra `01_pipeline_synthetic/templates/evidence_pack.template.json`. Copie como `evidence_pack_<buyer>.json`.

Preencha `identity_snapshot` com o perfil público do buyer. Para `content_items` e `comments_made`:

- LinkedIn: capture **10+ posts** dos últimos 6 meses + **10+ comentários** feitos pelo buyer em posts de terceiros.
- Se o buyer tem newsletter, blog, ou foi entrevistado em podcast → adicione em `external_assets`.

**Checkpoint:** rode `python 01_pipeline_synthetic/validators/coverage_gate.py evidence_pack_<buyer>.json`. Se não passar, colete mais antes de prosseguir. **Não force** o pipeline com cobertura insuficiente — a persona vai ser ruim.

### 2. Extração de sinais (30 min com IA)

Cole o conteúdo de `01_pipeline_synthetic/00_system_message.md` no system prompt do seu LLM.

Use `01_pipeline_synthetic/prompts/01_evidence_to_signals.prompt.md` com o `evidence_pack_<buyer>.json` como input.

Saída: o Pack agora tem `signals` populados (recurring_topics, explicit_problems, decision_criteria_mentions, rejected_ideas).

### 3. Job JSON (30 min com IA)

Use `01_pipeline_synthetic/prompts/02_signals_to_job.prompt.md`.

**Checkpoint crítico:** o `job.json` precisa ter `validation.ready_for_persona: true`. Se não, leia os `blockers` e volte para coletar mais evidência.

### 4. Persona (15 min com IA)

Use `01_pipeline_synthetic/prompts/03_job_to_persona.prompt.md`.

Saída: `persona_<buyer>.json` conformada ao schema, com `traceability` completa.

### 5. Sales prep derivada (1-2 horas, trabalho humano)

Agora você tem a matéria-prima. Derive os artefatos de venda:

#### A. Script de 5-7 perguntas calibradas

Para cada `decision_criteria` da persona, formule uma pergunta que valide se aquele critério está ativo *neste deal específico*. Exemplo:

- Persona tem `decision_criteria: ["Aceita só vendor com 99.95% SLA documentado"]`.
- Pergunta calibrada: *"Quando vocês trocaram de provider em 2024, o SLA documentado foi parte da decisão? Como vocês medem isso hoje internamente?"*

#### B. Lista de 3 objeções esperadas com respostas pré-preparadas

Para cada item em `objections` (rejeições explícitas do Job JSON), formule:
- Como essa objeção provavelmente aparece na conversa.
- 2-3 frases de resposta que **respeitam** a objeção sem se subordinar a ela.

#### C. "Bombas relógio" do deal

Procure no Evidence Pack por sinais de:
- Mudança recente de função (pode estar provando algo).
- Frustração pública com vendor atual (oportunidade).
- Iniciativas internas em curso que vão ditar timing.

### 6. Briefing de 1 página

Compile tudo num documento de 1 página com:
- 3 frases sobre quem é o buyer.
- O job-to-be-done principal.
- As 3 decision_criteria críticas.
- As 5-7 perguntas calibradas.
- As 3 objeções com respostas.
- As "bombas relógio" identificadas.

Isso é o que você lê 10 minutos antes da reunião.

---

## Checkpoints onde parar e perguntar

- **Após passo 1:** se o buyer tem menos de 10 posts E menos de 10 comentários, **não construa a persona**. Use outras táticas (referral check, conversa com champion interno) para coletar evidência adicional antes.
- **Após passo 3:** se `validation.ready_for_persona: false`, pare. Não prossiga.
- **Após passo 5C:** se você não conseguiu identificar nenhuma "bomba relógio" e o deal é >$50K, considere se sabe o suficiente para conduzir a conversa. Talvez seja melhor adiar a reunião.

---

## Modos de falha conhecidos

| Falha | Causa | Como evitar |
|---|---|---|
| Persona "genérica do setor" | Faltou cobertura mínima de comentários (são eles que revelam decisão) | Não pule o gate. Colete mais. |
| Persona conflita com o que o champion diz internamente | Champion tem viés; buyer pode performar diferente em público | Cruze: dê preferência a sinais consistentes entre LinkedIn público + comentários internos do champion |
| Perguntas calibradas soam "investigativas demais" | Falta calibração de tom | Use a `language_signature` da persona — replique o registro dela |
| Buyer não bate com a persona no dia | Persona estava certa, mas a janela mudou (promoção, mudança de meta, novo CFO) | Sempre revalide com o champion 24h antes |

---

## Variações

- **ABM (account-based)**: construa personas para 3-5 pessoas do mesmo comitê de compra. Veja `exec_decision_room.md` para combinar em simulação multi-agente.
- **Inbound qualificado**: pula passos 1-3 (a evidência veio do formulário + comportamento no site), vai direto para passos 4-6 com dados internos.
