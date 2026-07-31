# Manual: Security Guardian Skill

---

#### 🇺🇸 English
**What it does:**
This skill is the CLI security expert for RTK, focused on command injection, shell escaping, hook security, and malicious input handling. It applies automatically after filter changes, shell execution logic, or hook modifications — and manually before a release or after any security-sensitive change.

**Key Features:**
- **RTK-Specific Threat Model:** RTK executes shell commands from user input, parses untrusted output from git/cargo/gh, integrates with Claude Code hooks, and routes commands transparently. Each of those is an injection surface, ranked CRITICAL through LOW with its mitigation.
- **Audit by Question, Not by Vibe:** Every change is run through a fixed set of questions across input validation, shell execution, output parsing, and hook integration.
- **Paired Vulnerable/Safe Examples:** Each pattern shows the dangerous version and the safe rewrite side by side — `sh -c` with a formatted string versus the `Command` builder, which escapes arguments by construction.
- **Grep-able Detection:** Concrete `rg` patterns to find `.arg("-c")`, `Command::new("sh")`, and hand-rolled argument joining across the codebase.
- **Hook Hardening Checklist:** Verify the Claude Code context, resolve the absolute binary path (PATH hijacking), validate the version (downgrade attacks), and never `eval` or `source` untrusted files.
- **Parsing Safety:** Cap output size before parsing, validate format, bounds-check before slicing, and return `Result` instead of `unwrap()` — the four steps that turn a malicious-output crash into a clean error.
- **Whitelist over Blacklist:** Allowed commands are enumerated explicitly, because blacklists are trivially bypassed.

**Also covers:** the audit command reference, incident response, and the recorded command-injection advisory for rtk v0.16.0.

---

#### 🇧🇷 Português
**O que faz:**
Esta skill é a especialista em segurança de CLI do RTK, focada em command injection, shell escaping, segurança de hooks e tratamento de entrada maliciosa. Aplica-se automaticamente após mudanças em filtros, na lógica de execução de shell ou em hooks — e manualmente antes de um release ou depois de qualquer mudança sensível a segurança.

**Principais Recursos:**
- **Modelo de Ameaça Específico do RTK:** O RTK executa comandos de shell a partir de entrada do usuário, faz parse de saída não confiável de git/cargo/gh, integra com hooks do Claude Code e roteia comandos de forma transparente. Cada uma dessas coisas é uma superfície de injeção, ranqueada de CRITICAL a LOW com sua mitigação.
- **Auditoria por Pergunta, Não por Intuição:** Toda mudança passa por um conjunto fixo de perguntas sobre validação de entrada, execução de shell, parse de saída e integração com hooks.
- **Exemplos Vulnerável/Seguro em Par:** Cada padrão mostra a versão perigosa e a reescrita segura lado a lado — `sh -c` com string formatada versus o builder `Command`, que escapa argumentos por construção.
- **Detecção Grepável:** Padrões `rg` concretos para achar `.arg("-c")`, `Command::new("sh")` e junção manual de argumentos por toda a base.
- **Checklist de Endurecimento de Hook:** Verificar o contexto do Claude Code, resolver o caminho absoluto do binário (sequestro de PATH), validar a versão (ataque de downgrade), e nunca dar `eval` ou `source` em arquivo não confiável.
- **Segurança no Parse:** Limitar o tamanho da saída antes do parse, validar formato, checar limites antes de fatiar, e devolver `Result` em vez de `unwrap()` — os quatro passos que transformam um crash por saída maliciosa em erro limpo.
- **Whitelist em Vez de Blacklist:** Comandos permitidos são enumerados explicitamente, porque blacklist é trivialmente contornável.

**Também cobre:** a referência de comandos de auditoria, resposta a incidente, e o advisory registrado de command injection do rtk v0.16.0.
