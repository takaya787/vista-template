#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

if echo "$COMMAND" | grep -qiE 'rm\s+-rf\s+(/|~|\.)'; then
  jq -n '{ decision: "deny", reason: "rm -rf blocked by safety hook" }'
  exit 0
fi
if echo "$COMMAND" | grep -qiE 'git\s+push\s+.*--force.*(main|master)'; then
  jq -n '{ decision: "deny", reason: "force push to main/master blocked" }'
  exit 0
fi
if echo "$COMMAND" | grep -qiE 'git\s+reset\s+--hard'; then
  jq -n '{ decision: "deny", reason: "git reset --hard blocked" }'
  exit 0
fi
if echo "$COMMAND" | grep -qiE 'cat\s+.*\.(env|pem|secret)'; then
  jq -n '{ decision: "deny", reason: "reading secret files blocked" }'
  exit 0
fi

exit 0
