#!/bin/bash
# PreToolUse hook: inject Python environment rules when python3 is used
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only inject if command contains python3
if echo "$COMMAND" | grep -q 'python3'; then
  RULES_FILE="${CLAUDE_PROJECT_DIR}/.claude/rules/convention/python-environment.md"
  if [ -f "$RULES_FILE" ]; then
    echo "=== Python Environment Rules (auto-injected) ==="
    cat "$RULES_FILE"
  fi
fi

exit 0
