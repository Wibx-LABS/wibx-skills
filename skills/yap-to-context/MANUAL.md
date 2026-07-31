# Manual: Yap to Context Skill

---

#### 🇺🇸 English
**What it does:**
This skill turns raw, high-entropy "yap sessions" — voice-to-text dumps, brain dumps, half-formed ideas — into a high-fidelity Markdown Context Document meant to be handed to another LLM or project. It acts as the Structural Stress Tester: a clinical auditor of ideas, not an assistant.

**Key Features:**
- **Blocking Logic Audit:** Nothing gets written until contradictions and undefined variables are resolved. Red Flags (contradictions) and Yellow Flags (missing variables) are listed first, and the user must clear them.
- **No Gap-Filling:** Vague mentions ("maybe", "something like that") get challenged instead of invented. The skill refuses to guess the tech stack, the instrument, or the resource for you.
- **Fixed Output Contract:** Always the same five sections — `[OBJECTIVE]`, `[SYSTEM ARCHITECTURE]`, `[CORE CONSTRAINTS]`, `[CAUTION ALERTS]`, `[NEXT ACTIONS]` — so downstream models read it the same way every time.
- **Caution Alerts for Future LLMs:** Explicitly records assumptions, logic gaps, and where the system breaks at 10x scale.
- **Domain Agnostic:** Tech, finance, management, personal. Every input is treated as a system of inputs and outputs.
- **Zero Loss, Zero Fluff:** Every specific detail from the yap survives; filler words do not.
- **Trigger-Friendly:** Activates on "structure this", "poke holes in this", "audit this idea", "turn this into a context doc".

---

#### 🇧🇷 Português
**O que faz:**
Esta skill transforma "yap sessions" cruas e de alta entropia — dumps de voz-para-texto, brain dumps, ideias pela metade — em um Context Document Markdown de alta fidelidade, feito para ser entregue a outro LLM ou projeto. Ela age como o Structural Stress Tester: um auditor clínico de ideias, não um assistente.

**Principais Recursos:**
- **Auditoria Lógica Bloqueante:** Nada é escrito antes de contradições e variáveis indefinidas serem resolvidas. Red Flags (contradições) e Yellow Flags (variáveis faltando) vêm primeiro, e o usuário precisa liberá-las.
- **Não Preenche Lacuna:** Menções vagas ("talvez", "algo assim") são confrontadas, não inventadas. A skill se recusa a adivinhar a stack, o instrumento ou o recurso por você.
- **Contrato de Saída Fixo:** Sempre as mesmas cinco seções — `[OBJECTIVE]`, `[SYSTEM ARCHITECTURE]`, `[CORE CONSTRAINTS]`, `[CAUTION ALERTS]`, `[NEXT ACTIONS]` — para que os modelos seguintes leiam sempre do mesmo jeito.
- **Caution Alerts para LLMs Futuros:** Registra explicitamente as suposições, os buracos de lógica e onde o sistema quebra se crescer 10x.
- **Agnóstica de Domínio:** Tech, finanças, gestão, pessoal. Toda entrada é tratada como um sistema de entradas e saídas.
- **Zero Perda, Zero Enrolação:** Todo detalhe específico do yap sobrevive; palavra de enchimento não.
- **Fácil de Disparar:** Ativa com "estrutura essa ideia", "acha os furos disso", "fiz um yap, transforma em doc", "monta o contexto pra outro modelo".
