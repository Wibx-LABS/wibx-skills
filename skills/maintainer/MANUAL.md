# Manual: Maintainer Skill

---

#### 🇺🇸 English
**What it does:**
This skill plays maintainer over the open PRs of the configured `Wibx-LABS` repos. One invocation is one full deterministic sweep: collect, classify, act, report. It merges on its own only what is provably safe, and comments on everything else telling whoever opened the PR — human or agent — exactly what to do next. It solves the case where several agent instances open PRs on the same repo and start colliding with each other.

**Key Features:**
- **Pinned Org:** `Wibx-LABS` is hardcoded. Any slug from another owner aborts the whole sweep. That lock is what makes self-merging safe.
- **Five Bands:** Every PR falls into exactly one of `HOLD`, `CONFLICT`, `CI_RED`, `WAIT`, `MERGE` — first matching condition wins.
- **Merge Order Is the Value:** The `MERGE` band is sorted smallest-first, and two PRs sharing >50% of their files never merge in the same sweep. Wrong order is what creates the conflict queue in the first place.
- **Reclassify After Each Merge:** Re-reads the PR list after every merge instead of polling, so `mergeable` recalculation on GitHub's side resolves on the next sweep.
- **Anti-Spam by SHA:** Every comment carries a hidden `<!-- maintainer:<band>:<sha> -->` marker. Same band + same SHA is never posted twice; a new push means a new SHA means the state changed, so it comments again. Zero local state.
- **Never Merges Blind:** No CI configured is absence of signal, not a green light — it lands in `HOLD`. Drafts, `CHANGES_REQUESTED`, and >1000-line PRs (except upstream syncs) are held for you.
- **Loop-Safe:** Never calls `AskUserQuestion` mid-sweep, since that would stall `/loop`. Pending decisions go to an "Aguardando você" list and come back next pass.
- **Dry Mode:** `/maintainer dry` classifies and reports with zero merges and zero comments. Use it the first time.

**Usage:**
`/maintainer` (confirms repos, then sweeps) · `dry` (read-only) · `go` (no prompts, for loops) · `<repo>` (single repo). Combinable: `/maintainer dry wibx-skills`. Continuous: `/loop 10m /maintainer go`.

---

#### 🇧🇷 Português
**O que faz:**
Esta skill faz o papel de mantenedor sobre as PRs abertas dos repos configurados da org `Wibx-LABS`. Uma invocação é uma varredura determinística completa: coletar, classificar, agir, reportar. Mergeia sozinha só o que é comprovadamente seguro, e comenta em todo o resto instruindo quem abriu a PR — humano ou agente — sobre o próximo passo. Resolve o caso em que várias instâncias de agente abrem PR no mesmo repo e começam a colidir entre si.

**Principais Recursos:**
- **Org Fixa:** `Wibx-LABS` é hardcoded. Slug de qualquer outro owner aborta a varredura inteira. Essa trava é o que torna o auto-merge seguro.
- **Cinco Faixas:** Toda PR cai em exatamente uma de `HOLD`, `CONFLICT`, `CI_RED`, `WAIT`, `MERGE` — vence a primeira condição que casar.
- **A Ordem de Merge É o Valor:** A faixa `MERGE` é ordenada da menor para a maior, e duas PRs que compartilham >50% dos arquivos nunca mergeiam na mesma passada. Ordem errada é justamente o que cria a fila de conflito.
- **Reclassifica a Cada Merge:** Relê a lista de PRs depois de cada merge em vez de fazer polling, então o recálculo do `mergeable` no lado do GitHub resolve na passada seguinte.
- **Anti-Spam por SHA:** Todo comentário carrega o marcador oculto `<!-- maintainer:<faixa>:<sha> -->`. Mesma faixa + mesmo SHA nunca é postado duas vezes; push novo significa SHA novo, que significa estado mudado, então comenta de novo. Zero estado local.
- **Nunca Mergeia às Cegas:** Sem CI configurado é ausência de sinal, não sinal verde — cai em `HOLD`. Drafts, `CHANGES_REQUESTED` e PRs acima de 1000 linhas (exceto syncs de upstream) ficam segurados para você.
- **Seguro em Loop:** Nunca chama `AskUserQuestion` no meio da varredura, o que travaria o `/loop`. Decisões pendentes vão para a lista "Aguardando você" e reaparecem na próxima passada.
- **Modo Dry:** `/maintainer dry` classifica e reporta sem nenhum merge e nenhum comentário. Use assim na primeira vez.

**Uso:**
`/maintainer` (confirma os repos, depois varre) · `dry` (só leitura) · `go` (sem perguntas, para loops) · `<repo>` (um repo só). Combináveis: `/maintainer dry wibx-skills`. Contínuo: `/loop 10m /maintainer go`.
