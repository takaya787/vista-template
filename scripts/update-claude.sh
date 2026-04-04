#!/bin/bash
set -euo pipefail

# Claude Code Updater
# Updates Claude Code CLI and plugins.
#
# Usage:
#   bash ~/.vista/vista-template/scripts/update-claude.sh
#   curl -fsSL https://raw.githubusercontent.com/takaya787/vista-template/main/scripts/update-claude.sh | bash

# --- Update Claude Code CLI ---

if ! command -v claude &> /dev/null; then
  echo "Claude Code is not installed. Run install.sh to install."
else
  echo "Updating Claude Code (current: $(claude --version))..."
  claude update 2>/dev/null \
    && echo "Claude Code updated." \
    || echo "Warning: Failed to update Claude Code. Run manually: claude update"
fi

# --- Update Claude Code plugins ---

_update_plugin() {
  local plugin="$1"
  local name="${plugin%%@*}"
  if claude plugin list 2>/dev/null | grep -q "^  . ${name}"; then
    echo "Updating ${name} plugin..."
    claude plugin update "$name" --scope user 2>/dev/null \
      && echo "${name} plugin updated." \
      || echo "Warning: Failed to update ${name}. Run manually: claude plugin update ${name}"
  else
    echo "Warning: ${name} plugin not installed. Run install.sh to install."
  fi
}

_update_plugin "document-skills@anthropic-agent-skills"
_update_plugin "context7@claude-plugins-official"
_update_plugin "frontend-design@claude-plugins-official"
