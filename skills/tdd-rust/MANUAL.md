# Manual: TDD Rust Skill

---

#### 🇺🇸 English
**What it does:**
This skill enforces Red-Green-Refactor for RTK filter development. Every new filter follows the same loop: failing test against a real fixture, minimum implementation, cleanup, verified token savings, and a locked output format. It auto-triggers when you start implementing a filter or command.

**Key Features:**
- **Real Fixtures Only:** Test data is captured from the actual command (`git log -20 > tests/fixtures/git_log_raw.txt`), never invented. Synthetic data tests a filter against output that will never occur.
- **Savings Is a Test, Not a Claim:** Every filter carries an assertion that token reduction is ≥60%, checked at normal size and again on a 1000-line input. A filter that doesn't save tokens has no reason to exist.
- **Snapshot-Locked Output:** `insta` locks the output format; changes surface in `cargo insta review` instead of silently drifting.
- **Panic Is a Bug:** Empty input, malformed input and binary garbage all get explicit tests. A filter must return `Ok()` — best-effort or passthrough — never panic on unexpected output.
- **Fallback Wiring:** The `run()` pattern degrades to raw output with a warning on filter error, records tracking, and preserves the wrapped command's exit code.
- **Quality Gate:** `cargo fmt --all && cargo clippy --all-targets && cargo test` — all three green, zero clippy warnings, before moving on.
- **Named Anti-Patterns:** Synthetic fixtures, missing savings test, `unwrap()` in production, and `Regex::new` inside the filter (recompiles every call — use `lazy_static`).

**Done means:** the nine-item checklist at the end of the skill, from fixture through `main.rs` registration.

---

#### 🇧🇷 Português
**O que faz:**
Esta skill impõe Red-Green-Refactor no desenvolvimento de filtros do RTK. Todo filtro novo segue o mesmo loop: teste falhando contra fixture real, implementação mínima, limpeza, economia de token verificada, e formato de saída travado. Dispara sozinha quando você começa a implementar um filtro ou comando.

**Principais Recursos:**
- **Só Fixture Real:** Dado de teste é capturado do comando de verdade (`git log -20 > tests/fixtures/git_log_raw.txt`), nunca inventado. Dado sintético testa o filtro contra uma saída que nunca vai acontecer.
- **Economia É Teste, Não Promessa:** Todo filtro carrega uma assertion de que a redução de token é ≥60%, checada em tamanho normal e de novo numa entrada de 1000 linhas. Filtro que não economiza token não tem razão de existir.
- **Saída Travada por Snapshot:** O `insta` trava o formato de saída; mudanças aparecem no `cargo insta review` em vez de derivarem em silêncio.
- **Panic É Bug:** Entrada vazia, entrada malformada e lixo binário têm teste explícito. O filtro tem que devolver `Ok()` — best-effort ou passthrough — nunca dar panic com saída inesperada.
- **Fiação com Fallback:** O padrão `run()` degrada para a saída crua com aviso em caso de erro do filtro, registra o tracking, e preserva o exit code do comando embrulhado.
- **Portão de Qualidade:** `cargo fmt --all && cargo clippy --all-targets && cargo test` — os três verdes, zero warning do clippy, antes de seguir.
- **Anti-Padrões Nomeados:** Fixture sintética, teste de economia ausente, `unwrap()` em produção, e `Regex::new` dentro do filtro (recompila a cada chamada — use `lazy_static`).

**Pronto significa:** o checklist de nove itens no fim da skill, da fixture até o registro no `main.rs`.
