#!/bin/bash
# Audit hook: log all Write/Edit operations to .ai/audit/file-writes.log
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

LOG_DIR="${CLAUDE_PROJECT_DIR}/.ai/audit"
LOG_FILE="${LOG_DIR}/file-writes.log"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "${TIMESTAMP} [${TOOL}] ${FILE_PATH}" >> "$LOG_FILE"

exit 0
