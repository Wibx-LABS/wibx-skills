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
└── README.md
```

Cada skill vive em `skills/<nome>/SKILL.md`. O frontmatter YAML (`name` + `description`) define **quando** o agente ativa a skill; o corpo é o **como** (personas, processos, exemplos).

## 📦 Skills Principais

| Nome da Skill | Pasta | Descrição | Status |
| :--- | :--- | :--- | :--- |
| **Sexy Copy** | [`skills/sexy-copy`](./skills/sexy-copy) | Copywriting persuasivo de alta performance, com modo de compliance Wibx. | `Ativo` |
| **Wibx Presentations** | [`skills/wibx-presentations`](./skills/wibx-presentations) | Gera apresentações HTML self-contained no design system da Wibx. | `Ativo` |
| **Prompt Engineer** | [`skills/prompt-engineer`](./skills/prompt-engineer) | Estrutura sistemática para criar e otimizar prompts de alta performance. | `Ativo` |
| **ToT-H** | [`skills/tot-h`](./skills/tot-h) | Painel de 16 personas (engenharia + produto) em Tree of Thought sob disciplina PRISMA. | `Ativo` |
| **Skill Creator** | [`skills/skill-creator`](./skills/skill-creator) | Cria, edita, testa e mede a performance de skills. | `Ativo` |
| **PRISMA** | [`skills/prisma`](./skills/prisma) | Constrói personas sintéticas defensáveis e simulações multi-agente. | `Ativo` |
| **Docling Parser** | [`skills/docling-parser`](./skills/docling-parser) | Converte documentos (PDF/DOCX/PPTX/XLSX/HTML/imagens) em Markdown localmente, sem gastar tokens. | `Ativo` |
| **Frontend Design** | [`skills/frontend-design`](./skills/frontend-design) | Cria interfaces frontend distintas e de qualidade de produção. | `Ativo` |
| **n8n** | [`skills/n8n`](./skills/n8n) | Cria, modifica, faz deploy, testa e depura workflows do n8n. | `Ativo` |

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

## 🤝 Contribuindo

1. Crie `skills/<nova-skill>/SKILL.md` com frontmatter (`name` + `description`) e instruções.
2. Valide: `python scripts/quick_validate.py skills/<nova-skill>`.
3. Empacote: `python scripts/package_skill.py skills/<nova-skill> packages`.
4. Atualize este `README.md` e abra um Pull Request para revisão da equipe Wibx Labs.

---

<p align="center">
  <strong>Construído e mantido pela equipe Wibx Labs. Apenas para uso interno.</strong>
</p>
