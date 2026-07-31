# Manual: Swarm Skill

---

#### 🇺🇸 English
**What it does:**
This skill turns a backlog into a collision-free, multi-instance attack plan: it partitions the work into disjoint "fronts", scaffolds a shared `.swarm/` blackboard, and emits one paste-ready kickoff prompt per front for several **separate** Claude Code instances. The invoking session then becomes the manager — tracking the blackboard, chasing feeders, escalating — and writes no code.

**Key Features:**
- **Cost Gate First, Every Time:** Each instance is a separately-billed full session, so the `doctor` runs before anything is emitted: detect candidate fronts, collapse any pair that shares files, refuse below **4** disjoint fronts, state the `N× session` cost line, and wait for an explicit `y`. No confirmation, nothing is emitted.
- **Disjoint Ownership Is the Mechanism:** A front owns paths no other front touches. Overlapping drafts mean the independence test wasn't finished — merge them rather than hope.
- **Feeders Ship First:** Fronts whose decisions others need are flagged and ordered first; downstream fronts build behind a stubbed interface until the contract lands, so nobody sits blocked.
- **Shared Blackboard:** `.swarm/blackboard.md`, `contracts/` and `log.md` are what keep independent instances from diverging; the worker protocol is embedded by reference into every kickoff prompt.
- **Emit-Only by Default:** The human starts the instances, which keeps the expensive axis — how many instances — under human control.
- **Optional Auto-Launch:** macOS + alacritty only, and only after the doctor's `y`. Pre-creates worktrees serially (concurrent `git worktree add` would race on git's lock), then opens one titled, positioned window per front. Teardown via `swarm-down.sh`.

**Not to be confused with:** `superpowers:dispatching-parallel-agents`, which dispatches throwaway subagents inside one session sharing your context budget. Swarm coordinates several full, separately-billed instances through an external blackboard with worktree isolation.

---

#### 🇧🇷 Português
**O que faz:**
Esta skill transforma um backlog num plano de ataque multi-instância à prova de colisão: particiona o trabalho em "fronts" disjuntos, monta um blackboard compartilhado `.swarm/`, e emite um prompt de kickoff pronto para colar por front, para várias instâncias **separadas** do Claude Code. A sessão que invocou vira então a gerente — acompanha o blackboard, cobra os feeders, escala — e não escreve código.

**Principais Recursos:**
- **Portão de Custo Primeiro, Sempre:** Cada instância é uma sessão completa faturada à parte, então o `doctor` roda antes de qualquer emissão: detecta fronts candidatos, colapsa todo par que compartilhe arquivos, recusa abaixo de **4** fronts disjuntos, declara a linha de custo `N× sessão`, e espera um `y` explícito. Sem confirmação, nada é emitido.
- **Posse Disjunta É o Mecanismo:** Um front é dono de caminhos que nenhum outro toca. Rascunhos sobrepostos significam que o teste de independência não terminou — funda os dois em vez de torcer.
- **Feeders Entram Primeiro:** Fronts cujas decisões os outros precisam são sinalizados e ordenados primeiro; os fronts a jusante constroem atrás de uma interface stub até o contrato chegar, então ninguém fica travado.
- **Blackboard Compartilhado:** `.swarm/blackboard.md`, `contracts/` e `log.md` são o que impede instâncias independentes de divergirem; o protocolo do worker é embutido por referência em todo prompt de kickoff.
- **Só Emite, por Padrão:** O humano é quem inicia as instâncias, o que mantém o eixo caro — quantas instâncias — sob controle humano.
- **Auto-Launch Opcional:** Só macOS + alacritty, e só depois do `y` do doctor. Pré-cria as worktrees em série (`git worktree add` concorrente disputaria o lock do git), depois abre uma janela titulada e posicionada por front. Teardown via `swarm-down.sh`.

**Não confundir com:** `superpowers:dispatching-parallel-agents`, que despacha subagents descartáveis dentro de uma sessão só, dividindo o seu orçamento de contexto. O swarm coordena várias instâncias completas, faturadas à parte, por um blackboard externo com isolamento por worktree.
