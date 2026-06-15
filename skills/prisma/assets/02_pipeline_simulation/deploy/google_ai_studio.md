# Deploy: Google AI Studio (Gemini)

> Recomendado para simulações multi-persona longas com decisão estruturada. Gemini 3 Pro tem context window grande o suficiente para todos os 8 arquivos + histórico de conversa.

---

## Pré-requisitos

- Conta Google.
- Acesso a `aistudio.google.com`.
- Todos os 8 arquivos da simulação prontos e validados.

---

## Passo a passo

### 1. Acessar AI Studio

Acesse `https://aistudio.google.com`. Faça login.

### 2. Selecionar "Build"

No menu lateral, clique em **Build**. Você verá uma área de prompt + área de upload de arquivos.

### 3. Selecionar modelo

Modelo recomendado: **Gemini 3 Pro** (ou Gemini 1.5 Pro se 3 Pro não estiver disponível). Esse modelo lida bem com:
- Context window suficiente para todos os JSONs + Story Board.
- Function calling (útil para emit estruturado dos blocks).
- Instruction following longo.

### 4. Upload dos 8 arquivos

Arraste todos os arquivos para a área de upload:

- `story_board.md`
- `persona_<N>.json` (1 por persona)
- `speaking_balance.json`
- `response_structure.json`
- `group_dynamics.json`
- `behavioral_guidelines.json`
- `decision_logic.json`

**Verificação crítica:** confirme que TODOS os arquivos foram carregados antes de prosseguir. Se faltar 1, a simulação vai produzir comportamento incoerente.

### 5. Colar o Master Prompt

Cole o conteúdo de `master_prompt.md` (ver `templates/master_prompt.template.md`) na área de prompt.

### 6. Press "Build"

Clique em **Build**. O AI Studio vai compilar a simulação e gerar uma URL de uso.

---

## Iteração

Depois de testar:

1. Volte para o Build.
2. Edite o JSON que precisa ajuste (ex.: `speaking_balance.json` pesos).
3. Re-upload o arquivo modificado (mantém os outros).
4. Press Build de novo.

---

## Limitações conhecidas

- Gemini ocasionalmente ignora blocos `next_move_block` se o `response_structure.json` tem muitos campos opcionais. Solução: reduza `include_*` para os que importam.
- Function calling de Gemini é menos previsível que de Claude/GPT em outputs JSON longos. Se o `machine_summary_schema` está sendo violado, mude para prompt-puro (sem function call).

---

## Quando NÃO usar Google AI Studio

- Quando você precisa de tool use sofisticado (web search, code execution dentro da simulação) → use Claude Console.
- Quando o deploy precisa virar produto público com billing → use OpenAI Custom GPT.
