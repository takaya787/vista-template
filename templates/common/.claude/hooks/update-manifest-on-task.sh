#!/bin/bash
# PostToolUse: sync task IDs into manifest when add_task / expand_task is called.
# Fires only when .taskmaster/automations/.active exists (set by /automate skill).

INPUT=$(cat)

# --- Guard: active automation must exist ---
ACTIVE_FILE="${CLAUDE_PROJECT_DIR}/.taskmaster/automations/.active"
[ ! -f "$ACTIVE_FILE" ] && exit 0

SLUG=$(tr -d '[:space:]' < "$ACTIVE_FILE")
[ -z "$SLUG" ] && exit 0

MANIFEST="${CLAUDE_PROJECT_DIR}/.taskmaster/automations/${SLUG}/manifest.json"
[ ! -f "$MANIFEST" ] && exit 0

# --- Extract task IDs from MCP response ---
# task-master returns content as either:
#   tool_response[].text  (array of content blocks)
#   tool_response.content[].text
RESPONSE_TEXT=$(echo "$INPUT" | jq -r '
  (.tool_response // []) |
  if type == "array" then .[].text // empty
  elif type == "object" then (.content // [])[].text // empty
  else empty
  end
' 2>/dev/null)

# Pattern 1: "Task 15" / "task #15" (case-insensitive)
TASK_WORD_IDS=$(echo "$RESPONSE_TEXT" | grep -oEi 'task[[:space:]]+#?[0-9]+' | grep -oE '[0-9]+')
# Pattern 2: "id: 15"
ID_COLON_IDS=$(echo "$RESPONSE_TEXT" | grep -oE '\bid:[[:space:]]*[0-9]+' | grep -oE '[0-9]+')
# Pattern 3: "#15"
HASH_IDS=$(echo "$RESPONSE_TEXT" | grep -oE '#[0-9]+' | grep -oE '[0-9]+')
# Pattern 4: structured JSON id field in tool_response
STRUCTURED_IDS=$(echo "$INPUT" | jq -r '
  [.. | objects | select(has("id") and (.id | type == "number")) | .id | tostring] | .[]
' 2>/dev/null | grep -E '^[0-9]+$')

ALL_IDS=$(printf '%s\n%s\n%s\n%s\n' \
  "$TASK_WORD_IDS" "$ID_COLON_IDS" "$HASH_IDS" "$STRUCTURED_IDS" \
  | grep -E '^[0-9]+$' | sort -u)

[ -z "$ALL_IDS" ] && exit 0

# --- Update manifest.task_ids (deduplicated) ---
TMP=$(mktemp)
cp "$MANIFEST" "$TMP"

while IFS= read -r ID; do
  jq --arg id "$ID" '.task_ids += [$id] | .task_ids |= unique' "$TMP" \
    > "${TMP}.new" && mv "${TMP}.new" "$TMP"
done <<< "$ALL_IDS"

mv "$TMP" "$MANIFEST"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "${TIMESTAMP} [manifest] updated task_ids for '${SLUG}': added $(echo "$ALL_IDS" | tr '\n' ' ')" \
  >> "${CLAUDE_PROJECT_DIR}/.ai/audit/manifest.log" 2>/dev/null || true

exit 0
