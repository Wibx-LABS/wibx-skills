# Manual: n8n Skill

---

#### 🇺🇸 English
**What it does:**
This skill creates, modifies, deploys, tests, and debugs n8n workflows. It enforces strict JSON structural schemas and correct node connection parameters, then validates the workflow against a live n8n server using the bundled verification script.

**Key Features:**
- **Schema-Enforced Workflows:** Builds workflow JSON against strict structural schemas so nodes and connections are always valid.
- **Correct Connections:** Ensures node connection parameters are wired properly, avoiding the most common n8n breakages.
- **Automated Verification:** Runs `./scripts/test-workflow.sh` to validate workflow correctness directly on the server.
- **Full Lifecycle:** Covers creation, modification, deployment, testing, and debugging in one workflow.
- **Configurable Credentials:** Reads `N8N_API_URL` and `N8N_API_KEY` from the environment — copy `.env.example` to `.env` and fill in your values (the real `.env` is git-ignored, never committed).

---

#### 🇧🇷 Português
**O que faz:**
Esta skill cria, modifica, faz deploy, testa e depura workflows do n8n. Ela aplica schemas estruturais JSON rígidos e parâmetros corretos de conexão entre nós, e então valida o workflow contra um servidor n8n real usando o script de verificação incluído.

**Principais Recursos:**
- **Workflows com Schema:** Constrói o JSON do workflow contra schemas estruturais rígidos, mantendo nós e conexões sempre válidos.
- **Conexões Corretas:** Garante que os parâmetros de conexão entre nós estejam ligados corretamente, evitando as quebras mais comuns do n8n.
- **Verificação Automatizada:** Roda `./scripts/test-workflow.sh` para validar a correção do workflow direto no servidor.
- **Ciclo Completo:** Cobre criação, modificação, deploy, teste e depuração num único fluxo.
- **Credenciais Configuráveis:** Lê `N8N_API_URL` e `N8N_API_KEY` do ambiente — copie `.env.example` para `.env` e preencha seus valores (o `.env` real é git-ignored e nunca versionado).
