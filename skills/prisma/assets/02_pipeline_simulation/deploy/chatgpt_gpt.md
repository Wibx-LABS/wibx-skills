# Deploy: ChatGPT Custom GPT

> Recomendado quando você quer uma UI pronta, compartilhável via link, sem desenvolver aplicação.

---

## Pré-requisitos

- ChatGPT Plus/Team/Enterprise (Custom GPTs exigem assinatura).
- Todos os 8 arquivos da simulação prontos e validados.

---

## Passo a passo

### 1. Criar novo GPT

Acesse `chat.openai.com` → **My GPTs** → **Create**.

### 2. Configure tab

- **Name**: nome da simulação (ex.: "PRISMA — Seed Round Negotiation").
- **Description**: 1-2 linhas explicando o cenário.
- **Instructions**: cole o conteúdo de `master_prompt.md`.

### 3. Knowledge (uploads)

Faça upload dos arquivos:

- `story_board.md`
- `persona_<N>.json` (cada uma)
- `speaking_balance.json`
- `response_structure.json`
- `group_dynamics.json`
- `behavioral_guidelines.json`
- `decision_logic.json`

ChatGPT Custom GPTs aceitam até 20 arquivos como knowledge. Os arquivos ficam disponíveis no contexto via retrieval automático.

### 4. Capabilities

- ✅ **Web Browsing** — útil se a simulação precisa puxar dados atuais (ex.: cotações de mercado para uma negociação financeira).
- ✅ **Code Interpreter** — útil para `evaluation_dimensions` que envolvem cálculo numérico.
- ❌ **DALL-E** — geralmente não relevante para simulações.

### 5. Actions (opcional)

Para integração com sistemas externos (ex.: gravar o Post-Simulation Report num banco), configure Actions com OpenAPI schema.

### 6. Preview e teste

Use o painel de **Preview** à direita para testar antes de salvar. Itere até cobrir os modos de falha conhecidos.

### 7. Save & Share

- **Save** → fica disponível só para você.
- **Publish to anyone with the link** → compartilhável por URL.
- **Publish to GPT Store** → exige aprovação OpenAI; conteúdo precisa seguir guidelines.

---

## Limitações conhecidas

- **Memory persistence**: cada sessão é independente. O Post-Simulation Report da sessão A não aparece na sessão B. Solução: peça ao usuário copiar/salvar.
- **File retrieval**: ocasionalmente o GPT "esquece" um arquivo se a conversa é muito longa. Solução: no Master Prompt, instrua "Sempre consulte `<arquivo>.json` antes de responder".
- **JSON output strict**: Custom GPTs não suportam JSON mode strict. Para outputs JSON 100% válidos, use API direto.

---

## Quando NÃO usar Custom GPT

- Quando você precisa do model mais inteligente para character consistency → use Claude Opus 4.6 via Console.
- Quando o uso é interno e o time não tem ChatGPT Plus → use Google AI Studio.
