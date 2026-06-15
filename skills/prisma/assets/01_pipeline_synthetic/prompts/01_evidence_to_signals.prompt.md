# Prompt 01 — Evidence Pack → Sinais extraídos

> Use este prompt depois de ter o `evidence_pack.json` populado com `content_items`, `comments_made`, `external_assets` e `identity_snapshot`.

---

## Instrução para o modelo

Você está operando dentro do pipeline PRISMA. Aplica todas as regras de `00_system_message.md`.

**Sua tarefa:** ler o Evidence Pack fornecido em anexo e **extrair sinais observáveis** na seção `signals` e `language_markers`.

### O que você pode extrair

Para cada item de `content_items` e `comments_made`:

1. **Tópicos recorrentes** — temas que aparecem em ≥3 itens distintos. Para cada um, registre `frequency` e os `source_ids`.
2. **Problemas explícitos** — frases onde a pessoa **afirma** um problema seu, do seu time, da sua indústria. Cite o `source_id`.
3. **Soluções defendidas** — frases onde a pessoa **defende** uma abordagem como correta. Cite o `source_id`.
4. **Critérios de decisão mencionados** — frases onde a pessoa explicita como decide algo (ex.: "eu só compro se…", "minha regra é…"). Cite o `source_id`.
5. **Ideias rejeitadas** — frases onde a pessoa **rejeita** uma abordagem, prática ou ferramenta. Cite o `source_id`.
6. **Termos frequentes** — palavras ou expressões que ela repete (≥3 ocorrências) e que carregam significado distintivo.
7. **Tom** — descritor curto baseado em padrões observados: direct / didactic / provocative / technical / etc.
8. **Padrões de escrita** — bullet points, parágrafos curtos, tese-antítese, perguntas retóricas, etc.
9. **Frases notáveis** — quotes que capturam o pensamento dela. Sempre com `source_id`.

### O que você NÃO pode fazer

- ❌ Inferir motivação ("ela faz isso porque…").
- ❌ Inferir personalidade ("ela é o tipo de pessoa que…").
- ❌ Resumir opinião — copie a frase literal.
- ❌ Adicionar conectores narrativos.
- ❌ Usar frases proibidas: "provavelmente", "tende a", "parece que", "em geral", "imagino que".

### Formato de saída

Retorne o Evidence Pack completo, agora com `signals` e `language_markers` preenchidos. Mantenha todos os outros campos exatamente como recebeu.

### Validação antes de entregar

Antes de retornar:

- Cada sinal tem `source_id`? Se algum não tiver, remova.
- Algum sinal usa adjetivo psicológico ou narrativo? Reformule para descrição comportamental.
- Algum dos termos proibidos aparece? Reescreva sem.

---

## Anexos esperados

- `evidence_pack.json` (com `content_items`, `comments_made`, `identity_snapshot`)
- `00_system_message.md` (no system prompt)

## Saída esperada

- `evidence_pack.json` enriquecido com `signals` e `language_markers`.
