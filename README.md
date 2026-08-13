# WIBX SKILLs

<p align="center">
  <pre>
  _____________  __.___.____    .____       _________
 /   _____/    |/ _|   |    |   |    |     /   _____/
 \_____  \|      < |   |    |   |    |     \_____  \ 
 /        \    |  \|   |    |___|    |___  /        \
/_______  /____|__ \___|_______ \_______ \/_______  /
        \/        \/           \/       \/        \/ 
  </pre>
  <strong>O Hub Central para Skills de IA da Wibx</strong>
</p>

> Uma coleção abrangente de skills de IA especializadas, projetadas para aumentar a produtividade, automatizar fluxos de trabalho e padronizar as capacidades de IA em todos os departamentos da Wiboo.

---

## 🚀 Visão Geral

Este repositório é a fonte oficial de verdade para skills de IA da empresa. Cada skill é construída para ser modular, reutilizável e facilmente integrada nos nossos ecossistemas de agentes (Forge/Bifrost), no Claude Desktop e no Claude Code.

## 🗂 Estrutura do Repositório

```
wibx-skills/
├── skills/                  # Uma pasta por skill, cada uma com um SKILL.md
│   └── <nome-da-skill>/
│       ├── SKILL.md         # Frontmatter (name + description) + instruções
│       └── MANUAL.md        # (opcional) manual de uso bilíngue
├── scripts/
│   ├── skill_management.py  # CLI: lista e linka skills nos diretórios de agentes locais
│   ├── package_skill.py     # Empacota uma skill num arquivo .skill distribuível
│   ├── quick_validate.py    # Valida o frontmatter do SKILL.md
│   └── utils.py             # Helpers compartilhados
├── packages/                # Arquivos .skill prontos para importar (o entregável)
│   └── <nome-da-skill>.skill
├── docs/                    # Documentação interna
│   ├── plans/               # Planos de implementação
│   └── specs/               # Especificações
└── README.md
```

Cada skill vive em `skills/<nome>/SKILL.md`. O frontmatter YAML (`name` + `description`) define **quando** o agente ativa a skill; o corpo é o **como** (personas, processos, exemplos).

## 📦 Skills Principais

| Nome da Skill | Pasta | Descrição | Status |
| :--- | :--- | :--- | :--- |
| **Sexy Copy** | [`skills/sexy-copy`](./skills/sexy-copy) | Copywriting persuasivo de alta performance, com modo de compliance Wibx. | `Ativo` |
| **Tandera Audit** | [`skills/tandera-audit`](./skills/tandera-audit) | Auditoria técnica GEO/AEO de qualquer site (score T/G/C, gate de auditabilidade, metodologia Olho de Tandera v2.0). | `Ativo` |
| **Tandera SoV** | [`skills/tandera-sov`](./skills/tandera-sov) | Share of voice em LLMs com protocolo estatístico (n≥5 runs, roster 2026 c/ Meta AI, mapa de fontes citadas). | `Ativo` |
| **Tandera Conteúdo** | [`skills/tandera-conteudo`](./skills/tandera-conteudo) | Conteúdo citável por LLMs (narrativa própria, Q&A people-first) com gate de compliance WBX obrigatório. | `Ativo` |
| **Wibx Presentations** | [`skills/wibx-presentations`](./skills/wibx-presentations) | Gera apresentações HTML self-contained no design system da Wibx. | `Ativo` |
| **Prompt Engineer** | [`skills/prompt-engineer`](./skills/prompt-engineer) | Estrutura sistemática para criar e otimizar prompts de alta performance. | `Ativo` |
| **ToT-H** | [`skills/tot-h`](./skills/tot-h) | Painel de 16 personas (engenharia + produto) em Tree of Thought sob disciplina PRISMA. | `Ativo` |
| **Skill Creator** | [`skills/skill-creator`](./skills/skill-creator) | Cria, edita, testa e mede a performance de skills. | `Ativo` |
| **PRISMA** | [`skills/prisma`](./skills/prisma) | Constrói personas sintéticas defensáveis e simulações multi-agente. | `Ativo` |
| **Docling Parser** | [`skills/docling-parser`](./skills/docling-parser) | Converte documentos (PDF/DOCX/PPTX/XLSX/HTML/imagens) em Markdown localmente, sem gastar tokens. | `Ativo` |
| **Frontend Design** | [`skills/frontend-design`](./skills/frontend-design) | Cria interfaces frontend distintas e de qualidade de produção. | `Ativo` |
| **n8n** | [`skills/n8n`](./skills/n8n) | Cria, modifica, faz deploy, testa e depura workflows do n8n. | `Ativo` |
| **Refactor** | [`skills/refactor`](./skills/refactor) | Melhora estrutura e legibilidade do código sem mudar o comportamento externo. | `Ativo` |
| **Golang Pro** | [`skills/golang-pro`](./skills/golang-pro) | Go concorrente (goroutines/channels), microsserviços gRPC/REST, otimização com pprof e Go idiomático. | `Ativo` |
| **Swarm** | [`skills/swarm`](./skills/swarm) | Particiona um backlog em "fronts" paralelos e gera prompts para múltiplas instâncias separadas do Claude Code, coordenadas por um blackboard `.swarm/`. | `Ativo` |
| **Wibx Blueprint** | [`skills/wibx-blueprint`](./skills/wibx-blueprint) | Gera o WiBX Project Blueprint: 3 fases encadeadas de deep research (diagnóstico, mercado/custos, cruzamento) a partir do site da empresa, escritas na página Notion destino. | `Ativo` |
| **Maintainer** | [`skills/maintainer`](./skills/maintainer) | Papel de mantenedor sobre PRs de vários repos: classifica (verde/CI pendente/conflito/CI vermelho), mergeia só o que é seguro na ordem certa, e comenta instruindo quem abriu a PR. Contínuo via `/loop`. | `Ativo` |
| **Yap to Context** | [`skills/yap-to-context`](./skills/yap-to-context) | Auditoria lógica bloqueante de ideias cruas ("yap sessions"): expõe contradições e variáveis não definidas antes de sintetizar um Context Document Markdown para outros LLMs. | `Ativo` |
| **Ultraswarm** | [`skills/ultraswarm`](./skills/ultraswarm) | Variante extrema do swarm: plano primeiro, pilha de skills + caveman + RTK por front, modelo/esforço sob medida, trava `/goal` por worker, `/code-review ultra` por front e no merge, e dashboard ao vivo. | `Ativo` |
| **LABS Calendar** | [`skills/labs-calendar`](./skills/labs-calendar) | Ponte para subir qualquer item no LABS Calendar (Notion) — afazer, tarefa, reunião, entrega, marco ou evento — em qualquer área da Wibx, com data, tags e corpo estruturado. | `Ativo` |
| **Handoff** | [`skills/handoff`](./skills/handoff) | Gera um documento de handoff de sessão pra outra sessão retomar sem perda quando o contexto acaba: captura o estado VIVO (branch, PRs, processos em background, cwd, arquivos temporários), o próximo passo executável e as pegadinhas — grava num lugar durável + ponteiro na memória. | `Ativo` |
| **Security Audit** | [`skills/security-audit`](./skills/security-audit) | Varre um repo clonado atrás de malware, ataque de supply chain e ameaças à máquina host, antes de rodar código de terceiro. | `Ativo` |
| **Espolio** | [`skills/espolio`](./skills/espolio) | Intake de repo de terceiro: gates eliminatórios de licença, segurança e saúde, clone em quarentena com regras de opsec, e veredito ordenado por custo (descartar → canibalizar → vendorizar → forkar). | `Ativo` |
| **Wibx Brand** | [`skills/wibx-brand`](./skills/wibx-brand) | Fonte canônica dos tokens de marca da Wibx: cores do tema Admin Dashboard, tipografia e regras de uso. | `Ativo` |

### 🎧 CS Suite (Customer Success / Suporte)

Skills operacionais do time de CS da Wibx, feitas para **Claude Desktop / claude.ai** com MCP
Notion. Nenhum ID de Notion, nome ou credencial vive neste repo (ele é público): cada skill usa
`PLACEHOLDER_*` documentados em `references/config.md`, resolvidos pelas **Project Instructions
privadas** do projeto do time (repo de setup privado). Skill sem o mapa de IDs para e pergunta —
nunca adivinha destino.

| Nome da Skill | Pasta | Descrição | Status |
| :--- | :--- | :--- | :--- |
| **CS Notion Reporting** | [`skills/cs-notion-reporting`](./skills/cs-notion-reporting) | Roteador de demandas do CS: decide o destino certo (Tech, Design, Suporte, Produto, CS), monta o payload obrigatório, classifica N1/N2/N3 e aplica o formato canônico de bug. | `Draft` |
| **CS Budgeter** | [`skills/cs-budgeter`](./skills/cs-budgeter) | Calcula e valida budget de campanha: valor do ponto, taxa de 3,5%, base de débito por mecânica, saldo e validação contra o histórico. | `Draft` |
| **CS Campaign Strategy** | [`skills/cs-campaign-strategy`](./skills/cs-campaign-strategy) | Briefing de Estratégia no formato oficial + Checklist Mínimo Obrigatório, escolha de mecânica com limites de caracteres e triagem por tamanho. | `Draft` |
| **CS Campaign Validation** | [`skills/cs-campaign-validation`](./skills/cs-campaign-validation) | Gate pré-lançamento: checklist bloqueante de 9 itens (budget, saldo, card de Tech antes, briefing, aprovações, assets, datas). | `Draft` |
| **CS Reporter** | [`skills/cs-reporter`](./skills/cs-reporter) | Gera o relatório diário de tasks (alertas N1, status, indicadores) e o mensal de performance por carteira, direto do kanban/database via MCP. | `Draft` |

### 🦀 RTK Toolkit (Rust / CLI)

Skills voltadas ao desenvolvimento do RTK (codebase Rust/CLI).

| Nome da Skill | Pasta | Descrição | Status |
| :--- | :--- | :--- | :--- |
| **Security Guardian** | [`skills/security-guardian`](./skills/security-guardian) | Especialista em segurança CLI do RTK — command injection, shell escaping, segurança de hooks. | `Ativo` |
| **TDD Rust** | [`skills/tdd-rust`](./skills/tdd-rust) | Workflow TDD (Red-Green-Refactor) para filtros do RTK, com idioms Rust e snapshot tests (insta). | `Ativo` |
| **Ship** | [`skills/ship`](./skills/ship) | Workflow de release: build, commit, push e bump de versão automatizados. | `Ativo` |

## 🔒 Ferramentas de terceiros (forks Wibx-LABS, source-of-trust)

Tudo que rodamos vem de um fork **Wibx-LABS**, auditado (ClamAV + semgrep + osv-scanner +
review manual, veredito `SAFE TO RUN` em 2026-07-04) e **fixado por SHA**. Bump de versão =
re-auditar o novo SHA e atualizar o pin aqui. Instalação/pin são gerenciados pelo `devkit`.

**Plugins agregados** (instalam via este marketplace como `nome@wibx-skills`; SHA-pin no
`.claude-plugin/marketplace.json`):

| Plugin | Fork | Licença | SHA fixado | O que comprime |
| :--- | :--- | :--- | :--- | :--- |
| **ponytail** | [`Wibx-LABS/ponytail`](https://github.com/Wibx-LABS/ponytail) | MIT | `1688e69` | o **código** escrito (YAGNI) |
| **caveman** | [`Wibx-LABS/caveman`](https://github.com/Wibx-LABS/caveman) | MIT | `0f4a54a` | a **resposta** (prosa terse) |

**Ferramentas de host** (não são plugins de marketplace — binário/pacote instalado pelo
`devkit init`/`sync`, multiplataforma; viram no-op se ausentes; pin em `tools.<t>.ref` do
`.devkit.yaml`):

| Ferramenta | Fork | Licença | SHA auditado | Instalação |
| :--- | :--- | :--- | :--- | :--- |
| **rtk** | [`Wibx-LABS/rtk`](https://github.com/Wibx-LABS/rtk) | Apache-2.0 | `a56f2b0` | binário Rust (install.sh / `cargo install`) — hook reescreve comandos de shell. Deps CVE-free (quick-xml/anyhow bump, rtk#1). |
| **graphify** | [`Wibx-LABS/graphify`](https://github.com/Wibx-LABS/graphify) | MIT | `983da3c` | pacote pip; hooks de git reconstroem o grafo de código |

## 🚀 Instalação em um comando

O jeito mais rápido de ter tudo: o **pacote de economia de tokens** (rtk + graphify +
caveman + ponytail) **junto** com o catálogo completo de skills — num único comando, sem
depender do `devkit` (que é privado). Como este repo é **público**, dá pra rodar direto:

```bash
curl -fsSL https://raw.githubusercontent.com/Wibx-LABS/wibx-skills/main/install.sh | sh
# ou, de um clone:
sh install.sh
```

O instalador (`install.sh` → `scripts/install.py`, só stdlib) faz, a nível de **usuário**
(`~/.claude`, compartilhado por CLI, IDE e GUI do Claude Code):

1. **Host tools** — `rtk` (binário → `~/.local/bin`) e `graphify` (pip), fixados por SHA em
   [`install/pins.json`](./install/pins.json). No-op gracioso se faltar `curl`/`cargo`/`pip`.
2. **Plugins** — `claude plugin install {wibx-skills,caveman,ponytail}@wibx-skills` a partir
   deste marketplace (só quando o CLI `claude` existe).
3. **Settings** — faz **merge** (nunca sobrescreve) em `~/.claude/settings.json`:
   `enabledPlugins`, marketplace, env `CAVEMAN_DEFAULT_MODE`/`PONYTAIL_DEFAULT_MODE`, e os
   hooks do rtk/graphify. Respeita `CLAUDE_CONFIG_DIR`.
4. **Badges de statusline** — copia `install/hooks/*.sh` para `~/.claude/hooks/` e aponta o
   `statusLine` para `statusline-combined.sh`, que renderiza lado a lado todo badge
   `*-statusline.sh` presente (`[CAVEMAN] [GRAPHIFY] [PONYTAIL] [RTK 83%]` — o do rtk
   mostra a economia do `rtk gain` com cache de 5 min; o do graphify acende quando o
   projeto aberto tem `graphify-out/graph.json`). Statusline **custom existente nunca é
   sobrescrito**; badge novo = dropar um `*-statusline.sh` no diretório.
5. **Skills** — sincroniza o catálogo inteiro via `scripts/skill_management.py --sync`.

### Flags

| Flag | Efeito |
| :--- | :--- |
| _(nenhuma)_ | pack completo + todas as skills |
| `--tools-only` | só o pack (tools + plugins + settings), sem as skills |
| `--skills-only` | só o catálogo de skills |
| `--no-tools` | pula os binários rtk/graphify (mantém plugins/settings/skills) |
| `--desktop` | imprime o caminho best-effort para o app Claude Desktop |
| `--dry-run` | mostra tudo que faria, sem executar |
| `--check` | relatório de status (o que está instalado) |

### Onde funciona (matriz de setups)

| Setup | Pack executável (rtk/graphify/caveman/ponytail) | Skills |
| :--- | :--- | :--- |
| **Claude Code — CLI / IDE / GUI (local)** | ✅ completo (mesmo `~/.claude`, shell local roda os hooks) | ✅ symlink |
| **Claude Code na web (sandbox cloud)** | ⚠️ hooks rodam, mas o binário `rtk`/`graphify` precisa ser instalado **dentro do sandbox** (rode o `install.sh` lá), não na tua máquina | ✅ via plugin |
| **Claude Desktop (chat app) / claude.ai (web chat)** | ⚠️ best-effort: sem shell local → rtk/graphify **não** rodam; caveman/ponytail viram texto colado ([`install/desktop-preamble.md`](./install/desktop-preamble.md)) | ⬆️ upload `.skill` |

> [!NOTE]
> O `devkit` (privado) continua sendo o superset interno — ele já instala este mesmo pack +
> skills a nível de repositório com governança de CI/PR. Este instalador é o caminho
> **público e a nível de máquina**.

## 🛠 Como Usar

Há dois caminhos: importar o pacote `.skill` no Claude Desktop, ou linkar as skills localmente para o Claude Code / Antigravity.

### 🧩 Importar no Claude (Desktop)

1. **Pegue a Skill**: o arquivo `.skill` de cada skill está em [`packages/`](./packages).
2. **Configurações do Claude**: em **Settings > Skills**.
3. **Importar**: clique em **"Add Skill"** e faça upload do `.skill`.
4. **Verificar**: a skill deve aparecer ativa.

> [!NOTE]
> No Claude.ai (Web), o `.skill` é um ZIP — extraia e copie o conteúdo do `SKILL.md` para as **Instruções Personalizadas do seu Projeto**.

### 💻 Linkar localmente (Claude Code / Antigravity)

O script `scripts/skill_management.py` cria symlinks de cada skill nos diretórios de agentes do **seu** usuário (`~/.claude/skills`, `~/.gemini/...`). Os caminhos derivam da localização do script e do seu `HOME`, então funciona para qualquer pessoa que clone o repo.

```bash
# Listar todas as skills do workspace (com descrições)
python scripts/skill_management.py --list

# Ver a descrição de uma skill específica
python scripts/skill_management.py <nome-da-skill>

# Sincronizar UMA skill
python scripts/skill_management.py --sync <nome-da-skill>

# Sincronizar TODAS as skills e limpar symlinks órfãos
python scripts/skill_management.py --sync
```

Como o link é via symlink, **editar um `SKILL.md` aqui reflete imediatamente** nos agentes — sem passo de cópia.

> **Windows:** `os.symlink` exige Developer Mode (ou terminal Admin) — sem isso o SO
> retorna `WinError 1314`. O sync detecta essa falha e **cai automaticamente para uma
> cópia real** (`shutil`), então funciona sem privilégio nenhum. A diferença: a cópia
> **não** reflete edições ao vivo — rode o `--sync` de novo após editar uma skill (ou
> ligue o Developer Mode para voltar aos symlinks live-update). Skills órfãs em modo
> cópia não são auto-removidas na limpeza (só symlinks são), por segurança.

### 📦 Empacotar uma skill (gerar `.skill`)

```bash
# Valida o frontmatter e gera packages/<nome>.skill
python scripts/package_skill.py skills/<nome-da-skill> packages
```

O empacotador valida o frontmatter e exclui artefatos (`__pycache__`, `*.pyc`, `*.skill`, `.DS_Store`, `.env`, e a pasta `evals/` na raiz da skill).

### 🔐 Skill n8n — segredos

A skill `n8n` lê `N8N_API_URL` e `N8N_API_KEY` do ambiente. **Nenhum segredo é versionado** — copie o template e preencha localmente:

```bash
cp skills/n8n/.env.example skills/n8n/.env   # .env é git-ignored
```

## 📚 Guias

Material de conhecimento interno, fora do fluxo de skills. Abra o arquivo no navegador.

| Guia | Arquivo | Descrição |
|------|---------|-----------|
| **Guia de Maestria em IA** | [`docs/guias/guia-maestria-ia.html`](./docs/guias/guia-maestria-ia.html) | Traduzindo Intenção em Realidade — as 8 etapas do caminho de maestria em IA do Wibx LABS. Deck HTML de 21 slides, self-contained, navegável por teclado. |

## 🤝 Contribuindo

1. Crie `skills/<nova-skill>/SKILL.md` com frontmatter (`name` + `description`) e instruções.
2. Valide: `python scripts/quick_validate.py skills/<nova-skill>`.
3. Empacote: `python scripts/package_skill.py skills/<nova-skill> packages`.
4. Atualize este `README.md` e abra um Pull Request para revisão da equipe Wibx Labs.

---

<p align="center">
  <strong>Construído e mantido pela equipe Wibx Labs. Apenas para uso interno.</strong>
</p>
