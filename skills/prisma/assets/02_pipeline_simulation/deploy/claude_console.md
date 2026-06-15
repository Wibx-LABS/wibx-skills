# Deploy: Claude Console (Anthropic)

> Recomendado para simulações que precisam de tool use sofisticado, ou que serão consumidas via API por aplicação própria.

---

## Pré-requisitos

- Conta Anthropic Console (`console.anthropic.com`).
- Todos os 8 arquivos da simulação prontos e validados.

---

## Passo a passo

### 1. Acessar Workbench

Acesse `console.anthropic.com` → **Workbench**.

### 2. Configurar System Prompt

No campo **System** do Workbench, cole:

1. O conteúdo de `master_prompt.md`.
2. Em seguida, o conteúdo de cada arquivo JSON delimitado por seções claras:

```markdown
## STORY BOARD
<conteúdo de story_board.md>

## PERSONAS

### Persona: Alex Pierce
```json
<conteúdo de persona_alex.json>
```

### Persona: Dan Reilly
```json
<conteúdo de persona_dan.json>
```

## SPEAKING BALANCE
```json
<conteúdo de speaking_balance.json>
```

## RESPONSE STRUCTURE
```json
<conteúdo de response_structure.json>
```

## GROUP DYNAMICS
```json
<conteúdo de group_dynamics.json>
```

## BEHAVIORAL GUIDELINES
```json
<conteúdo de behavioral_guidelines.json>
```

## DECISION LOGIC
```json
<conteúdo de decision_logic.json>
```
```

### 3. Selecionar modelo

Recomendado: **Claude Opus 4.6** ou **Claude Sonnet 4.6**.
- Opus: melhor character consistency, melhor decision reasoning.
- Sonnet: mais barato, suficiente para simulações curtas (<15 turnos).

### 4. Configurar parâmetros

- `max_tokens`: 2000-4000 por turno (cabe response_structure completa).
- `temperature`: 0.7-0.9 (suficiente variabilidade sem virar caótico).
- `stop_sequences`: opcionalmente, para forçar paragem em delimitadores.

### 5. Mensagem inicial do usuário

Inicie a simulação com:

```
Start the simulation. Set the scene per the Story Board, have the first persona deliver the opening line per the Speaking Balance phase 1 weights, and emit the first status_block + next_move_block.
```

### 6. Iterar

Cada nova mensagem do usuário avança um turno. O Workbench mantém histórico — não recarregue o system prompt entre turnos.

---

## Conversão para API

Quando estiver satisfeito com a simulação no Workbench, exporte para API:

1. Clique em **Get Code** no canto do Workbench.
2. Use o snippet (Python, TypeScript ou cURL) na sua aplicação.
3. O system prompt fica fixo; o `messages` array carrega o histórico da conversa.

---

## Quando NÃO usar Claude Console

- Quando você precisa de UI public-facing sem desenvolver app → use OpenAI Custom GPT.
- Quando o budget é zero → use Google AI Studio (tem tier gratuito).
