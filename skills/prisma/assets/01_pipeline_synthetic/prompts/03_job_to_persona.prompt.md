# Prompt 03 — Job JSON → Persona Sintética

> Use este prompt depois de validar que `job.json` tem `validation.ready_for_persona: true`.

---

## Instrução para o modelo

Você está operando dentro do pipeline PRISMA. Aplica todas as regras de `00_system_message.md`.

**Sua tarefa:** converter o `job.json` em `persona.json` conformado ao schema. A Persona é **expressão** — não cria fatos novos, apenas reorganiza e traduz o Job JSON em formato narrativo acionável.

### A Persona pode

- Traduzir comportamento em linguagem narrativa de pessoa real.
- Simplificar JSON em parágrafo de prosa.
- Sugerir tom de comunicação coerente com a `language_signature` do Job JSON.
- Adicionar `meta_attributes` decorativos (identity_markers, archetypal_energy, narrative_arc, quote) **desde que** marcados em `traceability.fields_marked_decorative`.

### A Persona NÃO pode

- ❌ Adicionar fatos ausentes do Job JSON.
- ❌ Adicionar motivações, medos ou desejos que não derivem de `frictions`, `objections` ou `jobs_to_be_done`.
- ❌ Atribuir arquétipos psicológicos (MBTI, enneagrama, transtornos clínicos) sem evidência declarada.
- ❌ Usar frases proibidas: "provavelmente", "tende a", "parece que", "em geral", "imagino que".

### Mapa de derivação (Job JSON → Persona)

| Campo da Persona | Origem no Job JSON |
|---|---|
| `cognitive_frame_jtbd.functional_jobs` | `jobs_to_be_done` com `category: functional` |
| `cognitive_frame_jtbd.emotional_jobs` | `jobs_to_be_done` com `category: emotional` |
| `cognitive_frame_jtbd.social_jobs` | `jobs_to_be_done` com `category: social` |
| `behavioral_decision_dynamics.push_factors` | `frictions` |
| `behavioral_decision_dynamics.pull_factors` | `triggers` (positivos) + `decision_criteria` com priority alta |
| `behavioral_decision_dynamics.anxieties_barriers` | `objections` + contradições não resolvidas |
| `behavioral_decision_dynamics.habits_heuristics` | padrões observados em `signals` |
| `evidence_beliefs_triggers.information_they_trust` | `decision_criteria` com `confidence: high` |
| `evidence_beliefs_triggers.decision_triggers` | `triggers` |
| `evidence_beliefs_triggers.red_flags` | `objections` |
| `communication_style.tone` | `language_signature.tonal_register` |
| `communication_style.key_phrases` | `language_markers.notable_phrases` do Evidence Pack |
| `goals_and_outcomes` | `decision_criteria` + `jobs_to_be_done` reformulados como metas |

### Traceability obrigatória

Preencha `traceability`:

- `fields_derived_from_job`: lista todos os campos que tem origem direta em Job JSON.
- `fields_marked_decorative`: lista todos os campos de `meta_attributes` (que são decoração explícita).
- `fields_with_insufficient_evidence`: replica `job.insufficient_evidence_fields`.

### Bloqueios automáticos antes de gerar

Não gere a Persona se:

- `job.validation.ready_for_persona` é `false`.
- O Evidence Pack original está marcado como real mas é de figura pública identificável sem consentimento.
- Há atribuição de transtorno clínico em qualquer campo.

### Formato de saída

Retorne o `persona.json` conformado ao schema. Sem narrativa ao redor.

---

## Anexos esperados

- `job.json` (com `validation.ready_for_persona: true`)
- `evidence_pack.json` (para acessar `notable_phrases` e contexto)
- `01_pipeline_synthetic/schemas/persona.schema.json`
- `01_pipeline_synthetic/templates/persona.template.json`
- `00_system_message.md` (no system prompt)

## Saída esperada

- `persona.json` conformado ao schema, com `traceability` populada.
