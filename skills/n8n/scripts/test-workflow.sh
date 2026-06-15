#!/bin/bash
set -e

WORKFLOW_FILE=$1

if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

N8N_API_URL="${N8N_API_URL:-http://localhost:5678/api/v1}"
N8N_API_KEY="${N8N_API_KEY}"
N8N_BASE_URL=$(echo "$N8N_API_URL" | sed 's|/api/v1||')

if [ -z "$WORKFLOW_FILE" ]; then
  echo "Error: Specify a workflow JSON file path"
  exit 1
fi

if [ -z "$N8N_API_KEY" ]; then
  echo "Error: N8N_API_KEY is not defined in the environment or .env file"
  exit 1
fi

echo "=== Stage 1: Local Structural Validation ==="
if ! jq empty "$WORKFLOW_FILE" 2>/dev/null; then
  echo "[-] Invalid JSON structure detected"
  exit 1
fi
echo "[+] Structural JSON validation passed"

echo "=== Stage 2: Remote Deployment ==="
PAYLOAD=$(jq 'del(.meta)' "$WORKFLOW_FILE")
WORKFLOW_NAME=$(echo "$PAYLOAD" | jq -r '.name')

# PUT payload: send ONLY name+nodes+connections+settings to force n8n to publish
# updated nodes as new activeVersion. Sending extra fields (createdAt, versionId, etc.)
# causes n8n to keep the existing activeVersion unchanged — only this minimal set works.
PUT_PAYLOAD=$(echo "$PAYLOAD" | jq '{name, nodes, connections, settings: {"executionOrder": "v1"}}')

# Check if workflow with this name already exists
WORKFLOW_NAME_LOWER=$(echo "$WORKFLOW_NAME" | tr '[:upper:]' '[:lower:]')
EXISTING_ID=$(curl -s "$N8N_API_URL/workflows?limit=100" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  | jq -r --arg name "$WORKFLOW_NAME_LOWER" '.data[] | select((.name | ascii_downcase) == $name) | .id' | head -1)

if [ -n "$EXISTING_ID" ] && [ "$EXISTING_ID" != "null" ]; then
  echo "[~] Workflow '$WORKFLOW_NAME' exists (ID: $EXISTING_ID). Updating..."
  RESPONSE=$(curl -s -X PUT "$N8N_API_URL/workflows/$EXISTING_ID" \
    -H "X-N8N-API-KEY: $N8N_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$PUT_PAYLOAD")
  WORKFLOW_ID="$EXISTING_ID"
else
  echo "[+] Creating new workflow '$WORKFLOW_NAME'..."
  # POST: strip extra fields that cause "additional properties" errors on creation
  POST_PAYLOAD=$(echo "$PAYLOAD" | jq 'del(.activeVersion,.createdAt,.updatedAt,.id,.versionId,.activeVersionId,.versionCounter,.triggerCount,.shared,.tags,.staticData,.pinData) | .settings = {"executionOrder": "v1"}')
  RESPONSE=$(curl -s -X POST "$N8N_API_URL/workflows" \
    -H "X-N8N-API-KEY: $N8N_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$POST_PAYLOAD")
  WORKFLOW_ID=$(echo "$RESPONSE" | jq -r '.id')
fi

if [ -z "$WORKFLOW_ID" ] || [ "$WORKFLOW_ID" == "null" ]; then
  echo "[-] Deployment failed:"
  echo "$RESPONSE"
  exit 1
fi
echo "[+] Deployed. Workflow ID: $WORKFLOW_ID"

echo "=== Stage 3: Remote Test Execution ==="
WEBHOOK_PATH=$(echo "$PAYLOAD" | jq -r '[.nodes[] | select(.type == "n8n-nodes-base.webhook") | .parameters.path] | first // empty')
IS_ACTIVE=$(curl -s "$N8N_API_URL/workflows/$WORKFLOW_ID" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" | jq -r '.active')

if [ -z "$WEBHOOK_PATH" ] || [ "$WEBHOOK_PATH" == "null" ]; then
  echo "[!] No webhook trigger found. Run manually in n8n UI:"
  echo "    $N8N_BASE_URL/workflow/$WORKFLOW_ID"
  exit 0
fi

WEBHOOK_URL="$N8N_BASE_URL/webhook/$WEBHOOK_PATH"

if [ "$IS_ACTIVE" != "true" ]; then
  echo "[!] Workflow not active — webhook won't fire."
  echo "    Activate it once in n8n UI, then re-run this script."
  echo "    Webhook URL (once active): $WEBHOOK_URL"
  exit 0
fi

echo "[+] Triggering: $WEBHOOK_URL"
curl -s -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{}' > /dev/null

echo "[+] Polling execution status..."
MAX_WAIT=120
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
  EXEC_RESPONSE=$(curl -s "$N8N_API_URL/executions?workflowId=$WORKFLOW_ID&limit=1" \
    -H "X-N8N-API-KEY: $N8N_API_KEY")
  EXEC_COUNT=$(echo "$EXEC_RESPONSE" | jq '.data | length')
  FINISHED=$(echo "$EXEC_RESPONSE" | jq -r '.data[0].finished // "null"')
  STATUS=$(echo "$EXEC_RESPONSE" | jq -r '.data[0].status // "unknown"')

  if [ "$EXEC_COUNT" == "0" ] || [ "$FINISHED" == "null" ]; then
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    continue
  fi

  # Terminal states: finished=true OR status=error/crashed (n8n sometimes leaves finished=false on error)
  if [ "$FINISHED" == "true" ] || [ "$STATUS" == "error" ] || [ "$STATUS" == "crashed" ]; then
    if [ "$STATUS" == "success" ]; then
      echo "[+] Execution Success"
    else
      EXEC_ID=$(echo "$EXEC_RESPONSE" | jq -r '.data[0].id')
      echo "[-] Execution Failed (status: $STATUS, id: $EXEC_ID)"
      curl -s "$N8N_API_URL/executions/$EXEC_ID?includeData=true" \
        -H "X-N8N-API-KEY: $N8N_API_KEY" \
        | jq '[.data.resultData.runData | to_entries[] | select(.value[0].error != null) | {node: .key, error: .value[0].error.message}]'
      exit 1
    fi
    break
  fi
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
  echo "[-] Timed out after ${MAX_WAIT}s"
  exit 1
fi
