#!/bin/bash
# PreToolUse: ~/Library/LaunchAgents/ へのcpはcom.vista.で始まるファイルのみ許可
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# cp コマンドで ~/Library/LaunchAgents/ が宛先に含まれているか
if echo "$COMMAND" | grep -qE 'cp\s+.*Library/LaunchAgents'; then
  # コピー元ファイル名を取得（最後の引数の手前の引数）
  SRC=$(echo "$COMMAND" | grep -oE '\S+\.plist' | head -1)
  BASENAME=$(basename "$SRC")

  if ! echo "$BASENAME" | grep -qE '^com\.vista\.'; then
    jq -n --arg reason "LaunchAgentsへのcpはcom.vista.で始まるplistのみ許可されています（検出: $BASENAME）" \
      '{ decision: "deny", reason: $reason }'
    exit 0
  fi
fi

exit 0
