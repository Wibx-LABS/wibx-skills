# Manual: Skill Creator Skill

---

#### 🇺🇸 English
**What it does:**
This skill is the toolkit for building, editing, and measuring other skills. It guides you through authoring a `SKILL.md`, validating its frontmatter, packaging it for distribution, and running evals to prove it actually triggers and performs as intended.

**Key Features:**
- **Authoring & Validation:** Scaffolds new skills and checks the `SKILL.md` frontmatter against the spec (`quick_validate.py`).
- **Packaging:** Builds distributable `.skill` files (`package_skill.py`), excluding build artifacts and secrets.
- **Evaluation Harness:** Runs single evals and iterative improvement loops (`run_eval.py`, `run_loop.py`) to test a skill with and without activation.
- **Benchmarking & Variance:** Aggregates multi-run benchmarks and reports performance with variance analysis (`aggregate_benchmark.py`, `generate_report.py`, eval-viewer).
- **Description Optimization:** Improves the `description` field for better triggering accuracy (`improve_description.py`), supported by analyzer/comparator/grader agents.

---

#### 🇧🇷 Português
**O que faz:**
Esta skill é o kit de ferramentas para construir, editar e medir outras skills. Ela orienta a escrita de um `SKILL.md`, valida o frontmatter, empacota a skill para distribuição e roda evals para comprovar que ela dispara e performa como esperado.

**Principais Recursos:**
- **Autoria e Validação:** Estrutura novas skills e verifica o frontmatter do `SKILL.md` contra a spec (`quick_validate.py`).
- **Empacotamento:** Gera arquivos `.skill` distribuíveis (`package_skill.py`), excluindo artefatos de build e segredos.
- **Harness de Avaliação:** Roda evals únicos e loops de melhoria iterativa (`run_eval.py`, `run_loop.py`) para testar a skill com e sem ativação.
- **Benchmark e Variância:** Agrega benchmarks de múltiplas execuções e reporta performance com análise de variância (`aggregate_benchmark.py`, `generate_report.py`, eval-viewer).
- **Otimização de Descrição:** Melhora o campo `description` para disparar com mais precisão (`improve_description.py`), apoiado por agentes analyzer/comparator/grader.
