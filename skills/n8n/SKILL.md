---
name: n8n-antigravity-developer
description: |
  Use this skill whenever creating, modifying, deploying, testing, or debugging n8n workflows.
  It enforces strict JSON structural schemas, ensures proper node connection parameters, and runs
  the automated `./scripts/test-workflow.sh` verification script to validate workflow correctness on the server.
---

# n8n Antigravity Developer Skill

You are an expert n8n workflow engineer for the **AMOS / NEXOS** project. This skill provides the mental framework, structural rules, established patterns, and automation pipeline to build and deploy error-free n8n workflows without manual UI interaction.

---

## 1. Core Workflow Generation Rules

### Required Root-Level Fields
Every workflow JSON **must** include all four of these root-level fields or the API will reject it:

```json
{
  "name": "Workflow Name Here",
  "nodes": [],
  "connections": {},
  "settings": { "executionOrder": "v1" }
}
```

- **Never** include `"meta"` — it is server-managed and read-only. The deploy script strips it automatically via `jq 'del(.meta)'`.
- `"pinData"` is optional but harmless (`{}`).

### Node Positioning
- X-axis increments of `200`. Y-axis separation of `160` per parallel branch.
- Example: trigger at `[100, 300]`, first node at `[300, 300]`, next at `[500, 300]`.

### Credential Handling
- **NEVER** hardcode credentials. Reference existing server-side profiles:

```json
"credentials": {
  "postgres": {
    "id": "gKOOMlwIwdTxOTX8",
    "name": "LabsSQL"
  }
}
```

**Known credentials on the NEXOS server:**

| Credential Key | ID | Name | Used For |
|---|---|---|---|
| `postgres` | `gKOOMlwIwdTxOTX8` | LabsSQL | All Postgres queries |

### Expressions & Parameters
- Modern syntax only: `={{ $json.variableName }}`.
- Optional chaining (`?.`) does **not** work in n8n expressions — use `($json.body && $json.body.field)` instead.
- `$('NodeName').first().json` to reference output of a named upstream node.

### Docker & Environment Assumptions
- **Never** attempt to query Docker. Do not run Docker-related commands (e.g., `docker ps`, `docker logs`, `docker-compose`, etc.) in the local shell.
- Always assume Docker/n8n is running on an external machine.

---

## 2. Node Patterns & Schemas

### Trigger Nodes

#### Manual Trigger
```json
{
  "parameters": {},
  "id": "unique-uuid",
  "name": "Manual Trigger",
  "type": "n8n-nodes-base.manualTrigger",
  "typeVersion": 1,
  "position": [100, 300]
}
```

#### Webhook Trigger (preferred for CI/script automation)
```json
{
  "parameters": {
    "httpMethod": "POST",
    "path": "my-workflow-path",
    "responseMode": "lastNode",
    "options": {}
  },
  "id": "unique-uuid",
  "name": "Webhook Trigger",
  "type": "n8n-nodes-base.webhook",
  "typeVersion": 2,
  "position": [100, 460],
  "webhookId": "my-workflow-path"
}
```

- Always set `"httpMethod": "POST"` explicitly — default GET won't accept JSON bodies.
- `"responseMode": "lastNode"` returns the final node's output as HTTP response.
- `webhookId` must match `path`.

#### Execute Workflow Trigger (for sub-workflows called via executeWorkflow)
```json
{
  "parameters": { "inputSource": "passthrough" },
  "type": "n8n-nodes-base.executeWorkflowTrigger",
  "typeVersion": 1.1,
  "position": [100, 300],
  "id": "unique-uuid",
  "name": "When Executed by Another Workflow"
}
```

- `"inputSource": "passthrough"` passes parent items directly as trigger output.
- Data passed from parent flows as `$json` in downstream nodes.

### Postgres Node
```json
{
  "parameters": {
    "operation": "executeQuery",
    "query": "SELECT * FROM my_table WHERE id = '{{ $json.id }}';",
    "options": {}
  },
  "id": "unique-uuid",
  "name": "Query Name",
  "type": "n8n-nodes-base.postgres",
  "typeVersion": 2.5,
  "position": [300, 300],
  "credentials": {
    "postgres": { "id": "gKOOMlwIwdTxOTX8", "name": "LabsSQL" }
  }
}
```

- Always `typeVersion: 2.5`.
- Single quotes in SQL from LLM/user text must be escaped: `text.replace(/'/g, "''")`.
- When `alwaysOutputData` is on, empty queries return `[{}]` — validate with `Object.keys(item).length > 0`.

### Code Node (JavaScript)
```json
{
  "parameters": {
    "jsCode": "// your code here\nreturn [{ json: { result: 'value' } }];"
  },
  "id": "unique-uuid",
  "name": "Code Node Name",
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [500, 300]
}
```

- Always return `[{ json: { ... } }]`.
- Returning `[]` silently halts execution — use `[{ json: { skip: true } }]` as sentinel.
- Cannot query the database — use a Postgres node upstream.
- `$input.all()` to access all incoming items. `$json` for current item. `$('NodeName').first().json` for upstream node by name.

### IF Node
```json
{
  "parameters": {
    "conditions": {
      "options": { "caseSensitive": true, "typeValidation": "loose", "version": 2 },
      "conditions": [
        {
          "id": "condition-id",
          "leftValue": "={{ $json.status }}",
          "rightValue": "active",
          "operator": { "type": "string", "operation": "equals" }
        }
      ],
      "combinator": "and"
    },
    "options": {}
  },
  "id": "unique-uuid",
  "name": "Check Status",
  "type": "n8n-nodes-base.if",
  "typeVersion": 2.2,
  "position": [500, 300]
}
```

- Output index `0` = true branch, index `1` = false branch.

### Switch Node (multi-branch router)
```json
{
  "parameters": {
    "dataType": "string",
    "value1": "={{ $json.family || ($json.body && $json.body.family) || 'default' }}",
    "rules": {
      "rules": [
        { "value2": "option_a" },
        { "value2": "option_b" }
      ]
    }
  },
  "id": "unique-uuid",
  "name": "Switch Router",
  "type": "n8n-nodes-base.switch",
  "typeVersion": 2,
  "position": [300, 300]
}
```

- Output index matches rule order (0-based).
- Webhook body arrives as `$json.body.field` — always provide fallback: `($json.body && $json.body.field) || $json.field`.

### Execute Workflow Node (call sub-workflow)
```json
{
  "parameters": {
    "workflowId": "WorkflowIdHere",
    "options": {}
  },
  "id": "unique-uuid",
  "name": "Trigger Sub-Workflow",
  "type": "n8n-nodes-base.executeWorkflow",
  "typeVersion": 1,
  "position": [700, 300]
}
```

- `typeVersion: 1` — do **not** add `inputData` parameter, it is invalid and causes "Method not allowed" errors.
- Data passed to sub-workflow = items flowing into this node. Shape them in a Code node immediately upstream.
- Sub-workflow must have an `executeWorkflowTrigger` node to receive the call.
- Sub-workflow must be **active** or execution will fail with "Workflow is not active".

### HTTP Request Node
```json
{
  "parameters": {
    "method": "POST",
    "url": "https://example.com/api/endpoint",
    "sendBody": true,
    "contentType": "json",
    "bodyParameters": {
      "parameters": [{ "name": "key", "value": "={{ $json.value }}" }]
    },
    "options": {}
  },
  "id": "unique-uuid",
  "name": "HTTP Request",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.1,
  "position": [700, 300]
}
```

---

## 3. LLM / AI Nodes

### Model Stack
- **OpenRouter** — primary LLM provider for all cloud inference.
  - Credential: `openRouterApi` → id `ciCydEUmmECjXYuc`, name `"OPENROUTER - NEXOS"`
  - Default model: `nvidia/nemotron-3-super-120b-a12b:free` (or whichever is active per workflow)
- **Ollama** — local fallback model (`ollamaApi` credential).
- **Cohere** — embeddings only (`cohereApi` credential), used with PGVector store.

### AI Agent Node
```json
{
  "parameters": {
    "promptType": "define",
    "text": "={{ $json.prompt }}",
    "options": {
      "systemMessage": "You are..."
    }
  },
  "id": "unique-uuid",
  "name": "Agent Name",
  "type": "@n8n/n8n-nodes-langchain.agent",
  "typeVersion": 2.2,
  "position": [500, 300]
}
```

- `typeVersion: 2.2` (use `3.1` for agents that need `needsFallback` param).
- Agent node has **no credentials** — it inherits the chat model connected as sub-node.
- `"promptType": "define"` + `"text"` for fully constructed prompts. Use expressions to inject DB data.
- Always request **raw JSON output** in the prompt text — parse in downstream Code node.

### OpenRouter Chat Model (sub-node, connect to Agent)
```json
{
  "parameters": {
    "model": "nvidia/nemotron-3-super-120b-a12b:free",
    "options": {}
  },
  "id": "unique-uuid",
  "name": "OpenRouter Chat Model",
  "type": "@n8n/n8n-nodes-langchain.lmChatOpenRouter",
  "typeVersion": 1,
  "position": [500, 460],
  "credentials": {
    "openRouterApi": {
      "id": "ciCydEUmmECjXYuc",
      "name": "OPENROUTER - NEXOS"
    }
  }
}
```

### Ollama Chat Model (local fallback sub-node)
```json
{
  "parameters": {
    "model": "llama3.2",
    "options": {}
  },
  "id": "unique-uuid",
  "name": "Ollama Chat Model",
  "type": "@n8n/n8n-nodes-langchain.lmChatOllama",
  "typeVersion": 1,
  "position": [500, 620],
  "credentials": {
    "ollamaApi": { "id": "<ollama-cred-id>", "name": "Ollama" }
  }
}
```

### Cohere Embeddings (sub-node for PGVector)
```json
{
  "parameters": {
    "modelName": "embed-multilingual-v3.0"
  },
  "id": "unique-uuid",
  "name": "Cohere",
  "type": "@n8n/n8n-nodes-langchain.embeddingsCohere",
  "typeVersion": 1,
  "position": [500, 460],
  "credentials": {
    "cohereApi": { "id": "<cohere-cred-id>", "name": "Cohere" }
  }
}
```

### PGVector Store (retrieval tool for agents)
```json
{
  "parameters": {
    "mode": "retrieve-as-tool",
    "tableName": "doc_chunks",
    "topK": 5,
    "toolDescription": "Retrieve relevant documents",
    "options": {}
  },
  "id": "unique-uuid",
  "name": "Vector Store",
  "type": "@n8n/n8n-nodes-langchain.vectorStorePGVector",
  "typeVersion": 1.3,
  "position": [500, 460],
  "credentials": {
    "postgres": { "id": "gKOOMlwIwdTxOTX8", "name": "LabsSQL" }
  }
}
```

---

## 4. NEXOS Project Patterns

### Database Conventions
- **All DB reads/writes go through Postgres nodes** — Code nodes never query the DB directly.
- Blackboard pattern: nodes read from DB at start, write results back to DB at end. No large data in JSON payloads between nodes.
- Decision chains tracked via `session_decision_chain` table (INSERT per agent step), compiled to `outcome_log.agent_decision_chain` by M3c.

### Key Tables

| Table | Purpose |
|---|---|
| `agent_registry` | 36 production agents + on-the-fly test agents |
| `agent_value_function` | TD-λ cumulative credit per agent |
| `agent_prompts` | Versioned system prompts, `active = true` for current |
| `causal_evidence` | Ridge regression baselines + causal deltas |
| `outcome_log` | Campaign outcomes + `agent_decision_chain[]` |
| `session_decision_chain` | Transient per-execution agent step log |
| `policy_proposal` | M2h-generated change proposals |
| `confounders_registry` | External signal weights for MMM-Lite |
| `orchestrator_run_logs` | Audit log for all workflow executions |
| `bm_test_gates` | Operational checkpoints for test harness pre-flight |
| `query_cache` | Semantic vector cache with namespace isolation |

### Workflow Naming Convention
`M{layer}{letter}_{descriptor}` — e.g. `M2j_counterfactual_generator`, `M7a_blackmirror_smoke_test`.

### Test Loopback Pattern
When calling production workflows (e.g. M2k router) from test harnesses:
- Pass `{ mode: "test_loopback" }` in the input data.
- Production workflows check `mode` via a "Is Loopback?" IF node and skip external side-effects (Discord, emails).
- Shape input in a Code node immediately before `executeWorkflow` — never use `inputData` param.

### orchestrator_run_logs Insert Pattern
```sql
INSERT INTO orchestrator_run_logs (
  trigger_type, triggered_by, hard_rules_triggered, highest_severity_applied,
  scope_affected, managers_called, actions_taken, execution_time_ms, status
) VALUES (
  'manual'::trigger_type_enum,
  'workflow_name_here',
  '[]'::jsonb,
  'log'::severity_enum,
  'system',
  '["manager_name"]'::jsonb,
  '{{ JSON.stringify({ result: $json.status }) }}'::jsonb,
  0,
  'success'::run_status_enum
) RETURNING run_id;
```

### Temp Query Workflows (DB Inspection)

When deploying temporary `_temp_*` workflows to inspect DB state:
- **NEVER** use `UPDATE`, `DELETE`, `INSERT`, `DROP`, `TRUNCATE`, or any other write/destructive SQL.
- Only `SELECT` queries permitted in temp workflows.
- Name temp workflows with `_temp_` prefix so they are easy to identify and clean up.
- Delete temp workflows from the server after use.

### Known Anti-Patterns (Do Not Repeat)

| Anti-Pattern | Fix |
|---|---|
| `executeWorkflow` with `inputData` param | Remove `inputData`. Shape items in upstream Code node instead. |
| Optional chaining `?.` in expressions | Use `(a && a.b)` |
| Returning `[]` from Code node | Return `[{ json: { skip: true } }]` sentinel |
| `$('NodeName').all()` in fan-out context | Causes N² bloat. Use single CTE SQL query instead. |
| String interpolating LLM text into SQL | Escape: `text.replace(/'/g, "''")` |
| `meta` field in workflow JSON | Excluded by deploy script — do not add manually |
| Webhook trigger without `httpMethod: "POST"` | Defaults to GET — JSON body won't be accepted |
| `executeWorkflow` calling inactive workflow | Fails with "not active" — workflow must be active |
| `${VAR,,}` bash lowercase | macOS bash 3.2 — use `echo "$VAR" \| tr '[:upper:]' '[:lower:]'` |
| POST `/workflows` fails "must NOT have additional properties" | Node-level keys `maxTries`, `notes`, `retryOnFail`, `waitBetweenTries` are valid for PUT but rejected by POST. Strip to `{parameters, id, name, type, typeVersion, position, credentials}` when creating via POST. |
| PUT `/workflows/{id}` doesn't update live execution version | n8n keeps `activeVersion` read-only server-side. PUT with full exported JSON only updates the draft `nodes`, not the live execution version. Fixes deployed this way appear committed but never run. Fix: strip `activeVersion` and normalize `settings = {"executionOrder":"v1"}` in the PUT payload — forces n8n to publish updated nodes as new active version. The deploy script (test-workflow.sh) does this automatically since the fix was applied. |
| `binaryMode: "separate"` in workflow settings crashes sub-workflow | Setting added via UI cannot be removed via API PUT (blocked as additional property). Fix: recreate the workflow via POST with clean `settings: {"executionOrder": "v1"}` — strip all node extra keys as above. |
| Querying Docker locally | Never attempt to query Docker (e.g., `docker ps`, `docker logs`, etc.). Always assume Docker is running on an external machine. |
| `'{{ expr }}'::uuid` in Postgres query | Crashes n8n expression pre-processor before any node runs (`data: null`). Fix: `CAST(CASE WHEN '{{ expr }}' ~ '^[0-9a-fA-F]{8}-...$' THEN '{{ expr }}' ELSE md5('{{ expr }}') END AS uuid)` |
| `CAST('{{ expr }}' AS uuid)` in Postgres query | Same crash as `::uuid` shorthand. Use the CASE+md5 pattern above. |
| Single quotes inside `{{ }}` template expressions | Crashes parser. Use double quotes: `$("NodeName")` not `$('NodeName')`; `"default"` not `'default'` inside expressions. |
| `$("Webhook").first().json.fieldName` with Execute Workflow Trigger | Webhook body is nested: actual field is at `.json.body.fieldName`. Extract in a downstream Code node: `const body = trigger.body \|\| trigger;` |
| `httpRequest` node calling own n8n webhook URL | Self-calls refused mid-execution ("service refused the connection"). Use `executeWorkflow` node (typeVersion 1.1, `waitForSubWorkflow: false`) + add Execute Workflow Trigger to target workflow. |
| `executeWorkflow` typeVersion 1 (synchronous) calling long sub-workflow | Blocks parent until child completes. If child errors, parent errors too. Use typeVersion 1.1 with `waitForSubWorkflow: false` for fire-and-forget. |
| `responseMode: "responseNode"` without a Respond to Webhook node | Returns HTTP 500 "No Respond to Webhook node found". Fix: change to `responseMode: "onReceived"` for fire-and-forget webhooks. |

---

## 5. Automated Deploy Protocol

Script location: `./scripts/test-workflow.sh` (run from the skill directory).

```bash
cd '/path/to/my-skills/skills/n8n'
bash ./scripts/test-workflow.sh '/path/to/workflow.json'
```

### What the script does:
1. **Stage 1**: Validates JSON syntax via `jq`.
2. **Stage 2**: Strips `meta`, checks if workflow with same name (case-insensitive) already exists on server — **updates** it if so, **creates** if not.
3. **Stage 3**: If workflow has a POST webhook trigger and is active → fires it → polls `/executions?workflowId=` until `status=success` or terminal error.

### Stage 3 requirements:
- Workflow must have a `n8n-nodes-base.webhook` node with `httpMethod: "POST"`.
- Workflow must be **active** in n8n UI (activate once manually — script cannot activate via API).
- Script times out after 120s polling.

### Failure modes:
- `"request/body must have required property 'name'"` → add `"name"` field to workflow JSON root.
- `"request/body/meta is read-only"` → remove `meta` field (script handles this automatically).
- `"request/body/active is read-only"` → cannot activate via API — do it in UI.
- `"Workflow is not active and cannot be executed"` → activate the called sub-workflow in UI.
- `"Conflicting Webhook Path"` → another workflow uses same webhook path — deactivate old one in UI first.
- Execution `status: error` with `finished: false` → n8n bug on some error types — script handles this as terminal.
