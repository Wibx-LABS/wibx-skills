# Manual: Security Audit Skill

---

#### 🇺🇸 English
**What it does:**
This skill protects the host machine from threats hiding in cloned repos or already sitting on the system. Two modes: **repo scan** (default) and **system scan** (`--system`). The threat model is code that attacks *you* — your credentials, your processes, your machine — so the right time to run it is **before** you run or install the repo, not after.

**Key Features:**
- **Not a Code Quality Audit:** It hunts malware and supply-chain attacks, not bad style. Different question, different findings.
- **Catches Code That Runs Without You:** Git hooks, `.envrc`, `.vscode`, devcontainers — things that execute on clone, editor-open or install, before you ever launch anything explicitly.
- **Eight Mechanical Passes:** Dependencies, build scripts, code patterns, binaries, CI/CD, committed secrets (gitleaks over full git history, with regex fallback), and auto-execution. Missing optional tools degrade gracefully instead of aborting.
- **LLM Deep-Dive on Top:** Every flagged file gets read and analyzed for what patterns miss — obfuscated intent, logic bombs, multi-step attack chains, slow credential exfiltration, and social engineering in READMEs telling you to run something dangerous.
- **Streams Findings Live:** Output is not buffered, so you see problems as they surface rather than at the end.
- **Verdict, Not Just a List:** CRITICAL → QUARANTINE, HIGH → DO NOT RUN, MEDIUM/LOW → REVIEW REQUIRED, clean → SAFE TO RUN. The full report is saved to a dated Markdown file.

**Usage:**
`/security-audit` or "scan this repo" / "is this safe to run?" from inside the cloned directory · `/security-audit --system` for a full host inspection.

---

#### 🇧🇷 Português
**O que faz:**
Esta skill protege a máquina host de ameaças escondidas em repos clonados ou já presentes no sistema. Dois modos: **scan de repo** (padrão) e **scan de sistema** (`--system`). O modelo de ameaça é código que ataca *você* — suas credenciais, seus processos, sua máquina — então a hora certa de rodar é **antes** de executar ou instalar o repo, não depois.

**Principais Recursos:**
- **Não É Auditoria de Qualidade:** Ela caça malware e ataque de cadeia de suprimentos, não estilo ruim. Pergunta diferente, achados diferentes.
- **Pega Código Que Roda Sem Você:** Git hooks, `.envrc`, `.vscode`, devcontainers — coisas que executam no clone, na abertura do editor ou na instalação, antes de você lançar qualquer coisa explicitamente.
- **Oito Passadas Mecânicas:** Dependências, scripts de build, padrões de código, binários, CI/CD, segredos commitados (gitleaks sobre todo o histórico git, com fallback de regex) e auto-execução. Ferramentas opcionais ausentes degradam com elegância em vez de abortar.
- **Deep-Dive de LLM por Cima:** Todo arquivo sinalizado é lido e analisado para o que padrão nenhum pega — intenção ofuscada, bombas lógicas, cadeias de ataque em múltiplos passos, exfiltração lenta de credencial e engenharia social em README mandando você rodar algo perigoso.
- **Streama os Achados ao Vivo:** A saída não é bufferizada, então você vê os problemas conforme aparecem, não só no fim.
- **Veredito, Não Só Lista:** CRITICAL → QUARANTINE, HIGH → DO NOT RUN, MEDIUM/LOW → REVIEW REQUIRED, limpo → SAFE TO RUN. O relatório completo é salvo num arquivo Markdown datado.

**Uso:**
`/security-audit` ou "scan this repo" / "isso é seguro de rodar?" de dentro do diretório clonado · `/security-audit --system` para inspeção completa do host.
