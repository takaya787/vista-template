#!/bin/bash
# Audit hook (PostToolUse): log all executed Bash commands to .ai/audit/commands.log
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_response.exit_code // "?"')

[ -z "$COMMAND" ] && exit 0

LOG_DIR="${CLAUDE_PROJECT_DIR}/.ai/audit"
LOG_FILE="${LOG_DIR}/commands.log"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
# Truncate long commands for readability
SHORT_CMD=$(echo "$COMMAND" | head -c 200 | tr '\n' ' ')
echo "${TIMESTAMP} [exit:${EXIT_CODE}] ${SHORT_CMD}" >> "$LOG_FILE"

exit 0
