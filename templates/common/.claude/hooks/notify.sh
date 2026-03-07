#!/bin/bash
INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')

# --- Project path ---
PROJECT_NAME=""
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
  PROJECT_NAME="[$(basename "$CLAUDE_PROJECT_DIR")] "
fi

# --- Build notification message ---
case "$EVENT" in
  Notification)
    TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')
    MSG=$(echo "$INPUT" | jq -r '.message // empty')
    case "$TYPE" in
      permission_prompt)
        TITLE="${PROJECT_NAME}Permission required"
        BODY="${MSG:-Waiting for tool execution permission}"
        SOUND="true"
        AUTOCLOSE="false"
        ;;
      idle_prompt)
        TITLE="${PROJECT_NAME}Waiting for input"
        BODY="${MSG:-Claude Code is waiting for a response}"
        SOUND="true"
        AUTOCLOSE="false"
        ;;
      *)
        exit 0
        ;;
    esac
    ;;
  Stop)
    IS_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
    [ "$IS_ACTIVE" = "true" ] && exit 0

    TITLE="${PROJECT_NAME}Task complete"
    PREVIEW=$(echo "$INPUT" | jq -r '.last_assistant_message // ""' | head -c 80 | tr '\n' ' ')
    BODY="${PREVIEW:-Response completed}..."
    SOUND="false"
    AUTOCLOSE="true"
    ;;
  *)
    exit 0
    ;;
esac

# --- OS detection → native notification ---
case "$(uname -s)" in
  Darwin)
    if [ "$AUTOCLOSE" = "true" ]; then
      osascript -e "display alert \"$TITLE\" message \"$BODY\" giving up after 5"
    else
      osascript -e "display alert \"$TITLE\" message \"$BODY\""
    fi
    if [ "$SOUND" = "true" ]; then
      afplay /System/Library/Sounds/Blow.aiff &
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    powershell.exe -NoProfile -Command \
      "[void](New-Object -ComObject WScript.Shell).Popup('$BODY',5,'$TITLE',64)" &
    ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      powershell.exe -NoProfile -Command \
        "[void](New-Object -ComObject WScript.Shell).Popup('$BODY',5,'$TITLE',64)" &
    else
      notify-send "$TITLE" "$BODY" 2>/dev/null || true
    fi
    ;;
esac

exit 0
