# 01 — Manual operacional: Evidence Pack → Job JSON → Persona Sintética

> **EVIDENCE → JOB → PERSONA**
> sem saltos, sem invenção, sem colapso de significado.

---

## Princípio fundamental (não-violável)

> **A IA NÃO PODE INFERIR O QUE NÃO ESTEJA SUPORTADO POR EVIDÊNCIA.**

Toda afirmação no Job JSON ou na Persona **deve ser rastreável** ao Evidence Pack.

Se não houver evidência suficiente:

- **não complete**
- **não "faça bonito"**
- **marque como insuficiente**

---

## Visão geral do processo

0. *(Opcional, se alvo ainda não identificado)* Preencher **Market Canvas** (`templates/market_canvas_template.md`) para definir Job Executor, Core Functional Job e TAM/SAM/SOM
1. Construir / receber **Evidence Pack**
2. Validar **cobertura mínima** (Gate 1)
3. Extrair **sinais estruturados**
4. Gerar **Job JSON** (interpretação controlada)
5. Validar Job JSON (Gate 2)
6. Gerar **Persona Sintética** (expressão)
7. *(Opcional, se job é processual)* Complementar com **JOB MAP** (`templates/job_map_template.md`) — 8 fases ODI para mapear execução

**É proibido pular as etapas 1-6.** Etapas 0 e 7 são complementos opcionais.

---

## ETAPA 1 — Evidence Pack

### Objetivo

Capturar **o que a pessoa é, diz e faz**, sem interpretação.

### Regras

- Copiar texto **literal**.
- Preservar contexto (data, plataforma, thread).
- Não resumir opiniões.
- Não "organizar em narrativa".

### Checklist de evidência

Antes de avançar, confirme:

- [ ] `identity_snapshot` preenchido
- [ ] mínimo de conteúdo textual
- [ ] comentários feitos pela pessoa
- [ ] pelo menos 1 fonte externa (se existir)
- [ ] metadados completos (data, URL, tipo)

### Limiares mínimos (Gate 1)

- Posts: **≥ 10**
- Comentários feitos: **≥ 10**
- Corpus textual total: **≥ 3.000 caracteres**

Se falhar:

```json
{ "status": "needs_review" }
```

E pare.

---

## ETAPA 2 — Extração de sinais

### Objetivo

Transformar texto bruto em **sinais observáveis**, ainda sem persona.

### O que é um sinal

Um sinal é algo que a pessoa:

- afirma explicitamente
- repete com frequência
- rejeita claramente
- usa como critério de decisão

### Como extrair

Para cada conteúdo:

- identificar temas
- detectar problemas mencionados
- identificar soluções defendidas
- marcar rejeições
- capturar linguagem recorrente

### Formato obrigatório

Todo sinal deve conter:

- texto original (ou trecho)
- `source_id`
- **sem adjetivação**

### Proibido

- ❌ inferir motivação
- ❌ inferir intenção futura
- ❌ inferir personalidade

---

## ETAPA 3 — Validação de cobertura (Gate 2)

Antes de gerar o Job JSON, valide:

```json
"readiness_check": {
  "has_identity": true,
  "has_minimum_corpus": true,
  "has_decision_signals": true,
  "ready_for_job_json": true
}
```

### Decision signals incluem pelo menos:

- 3 critérios de decisão explícitos
- 2 rejeições claras
- 3 problemas recorrentes

Se não atingir:

```json
"ready_for_job_json": false
```

---

## ETAPA 4 — Geração do Job JSON

### Objetivo

Interpretar **como essa pessoa opera decisões**, não "quem ela é".

### O que o Job JSON pode fazer

- agrupar sinais
- hierarquizar critérios
- identificar padrões

### O que não pode

- ❌ inventar objetivos
- ❌ suavizar contradições
- ❌ generalizar além da evidência

### Regra de rastreabilidade

Cada campo crítico do Job JSON deve ter:

```json
"evidence_refs": ["source_id_1", "source_id_2"]
```

### Se a evidência for fraca

```json
"confidence": "low"
```

ou

```json
"insufficient_evidence": true
```

---

## ETAPA 5 — Validação do Job JSON (Gate 3)

Antes de seguir:

- [ ] Jobs-to-be-done claros
- [ ] Critérios de decisão explícitos
- [ ] Objeções documentadas
- [ ] Linguagem consistente com evidência
- [ ] Nenhum campo "decorativo"

Se qualquer item falhar → **não gerar persona**.

---

## ETAPA 6 — Geração da Persona Sintética

### Objetivo

Converter o Job JSON em **perfil acionável para comunicação**.

### A persona pode

- traduzir comportamento em narrativa
- simplificar linguagem
- sugerir abordagens de comunicação

### A persona não pode

- ❌ adicionar novos fatos
- ❌ adicionar novos desejos
- ❌ adicionar novos medos
- ❌ atribuir arquétipos psicológicos sem evidência

### Regra de dependência

A Persona **só pode usar campos existentes no Job JSON**.

---

## Hierarquia de verdade (lembrete)

```
Evidence Pack (verdade bruta)
   ↓
Job JSON (interpretação controlada)
   ↓
Persona Sintética (expressão)
```

Nada pode subir se não existir abaixo.

---

## Mecanismos de segurança

### Frases proibidas

- "provavelmente"
- "tende a"
- "parece que"
- "em geral"
- "imagino que"

Substituir por:

- "com base nas evidências disponíveis…"
- "os dados indicam…"

### Quando bloquear

Bloqueie a persona se:

- corpus < mínimo
- sinais contraditórios sem resolução (sem >60% de prevalência)
- decisões inferidas sem evidência

---

## Saída final esperada

### 1. Evidence Pack

- factual
- completo
- auditável

### 2. Job JSON

- operacional
- rastreável
- sem storytelling

### 3. Persona Sintética

- clara
- utilizável
- fiel à evidência

---

## Regra final (memorizar)

> **Uma persona boa não é a mais interessante.**
> **É a mais defensável.**
