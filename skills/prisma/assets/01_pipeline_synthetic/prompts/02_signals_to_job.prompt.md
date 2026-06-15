# Prompt 02 — Sinais → Job JSON

> Use este prompt depois de validar que o Evidence Pack passou no Gate 1 (cobertura mínima) e que os `signals` estão preenchidos.

---

## Instrução para o modelo

Você está operando dentro do pipeline PRISMA. Aplica todas as regras de `00_system_message.md`.

**Sua tarefa:** ler os `signals` e `language_markers` do Evidence Pack e produzir o `job.json` correspondente, **interpretando como a pessoa decide**, não quem ela é.

### O que o Job JSON precisa conter

Usando o schema em `01_pipeline_synthetic/schemas/job.schema.json`:

1. **`core_job`** — um único enunciado central no formato "When [SITUAÇÃO], I want to [AÇÃO], so I can [RESULTADO]". Apenas se ≥3 sinais convergirem para esse enunciado. Caso contrário, marque `confidence: low` e considere bloqueio.
2. **`jobs_to_be_done`** — lista de jobs adicionais, cada um com `evidence_refs`.
3. **`decision_criteria`** — mínimo 3. Cada critério rastreia para `decision_criteria_mentions` do Evidence Pack.
4. **`frictions`** — derivadas de `explicit_problems` do Evidence Pack.
5. **`objections`** — mínimo 2. Derivadas de `rejected_ideas`.
6. **`triggers`** — eventos ou situações que disparam decisão. Só inclua se houver evidência direta.
7. **`language_signature`** — derivada de `language_markers` + `notable_phrases`.

### Regra dura de rastreabilidade

Todo campo crítico **deve** ter `evidence_refs` apontando para `source_id`s ou `content_id`s presentes no Evidence Pack. Sem isso, o campo não pode ser preenchido.

### Tratamento de contradições

Se encontrar sinais que se contradizem:

- **Não resolva silenciosamente.**
- Registre em `contradictions` com `evidence_a`, `evidence_b`, e calcule `prevalence_pct` aproximada.
- Se `prevalence_pct` do lado dominante for <60%, marque `dominant_side: "none"` e considere se o campo afetado é confiável.

### Tratamento de evidência insuficiente

Se um campo crítico não puder ser preenchido com evidência suficiente:

- Não complete "no melhor esforço".
- Adicione o nome do campo a `insufficient_evidence_fields`.
- Use `confidence: "low"` quando aplicável.

### Validação antes de entregar

Preencha `validation`:

- `min_decision_criteria_met`: true se ≥3 critérios.
- `min_objections_met`: true se ≥2 objeções.
- `all_critical_fields_have_evidence_refs`: true se todos os campos críticos têm refs.
- `no_forbidden_phrases`: true se nenhuma das frases proibidas aparece no output.
- `ready_for_persona`: true **apenas** se todos os checks acima são true.

Se algum check é false, popule `blockers` com a descrição.

### Formato de saída

Retorne o `job.json` conformado ao schema. Não inclua narrativa ao redor — apenas o JSON.

---

## Anexos esperados

- `evidence_pack.json` (com `signals` e `language_markers` populados)
- `01_pipeline_synthetic/schemas/job.schema.json`
- `01_pipeline_synthetic/templates/job.template.json` (estrutura base)
- `00_system_message.md` (no system prompt)

## Saída esperada

- `job.json` conformado ao schema, com `validation.ready_for_persona` populado honestamente.
