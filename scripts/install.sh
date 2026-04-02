#!/bin/bash
set -euo pipefail

# Vista Template Installer (curl-friendly)
# Downloads vista-template to ~/.vista/vista-template (persistent) and deploys to a target directory.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/takaya787/vista-template/main/scripts/install.sh | bash -s -- <target>

REPO_TARBALL="https://github.com/takaya787/vista-template/archive/refs/heads/main.tar.gz"
EXTRACTED_DIR_NAME="vista-template-main"
VISTA_HOME="${VISTA_HOME:-$HOME/.vista/vista-template}"
FORCE="${VISTA_FORCE:-true}"

# --- Usage ---

usage() {
  echo "Vista Template Installer"
  echo ""
  echo "Usage:"
  echo "  install.sh <target-directory>"
  echo ""
  echo "Examples:"
  echo "  curl -fsSL .../install.sh | bash -s -- ~/my-project"
  echo ""
  echo "Environment:"
  echo "  VISTA_HOME    Override install path (default: ~/.vista/vista-template)"
  echo "  VISTA_FORCE   Skip confirmation prompts (default: true)"
}

# --- Argument parsing ---

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

TARGET_DIR="$1"

# --- Install vista-template to persistent location ---

echo "Installing vista-template to $VISTA_HOME..."
[ -d "$VISTA_HOME" ] && rm -rf "$VISTA_HOME"
mkdir -p "$(dirname "$VISTA_HOME")"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

curl -fsSL "$REPO_TARBALL" | tar -xz -C "$WORK_DIR"

if [ ! -d "$WORK_DIR/$EXTRACTED_DIR_NAME" ]; then
  echo "Error: Failed to extract repository."
  exit 1
fi

mv "$WORK_DIR/$EXTRACTED_DIR_NAME" "$VISTA_HOME"
echo "Installed to $VISTA_HOME"

# --- Install Claude Code CLI ---

if ! command -v claude &> /dev/null; then
  echo "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | sh
else
  echo "Claude Code already installed: $(claude --version). Updating..."
  claude update 2>/dev/null \
    && echo "Claude Code updated." \
    || echo "Warning: Failed to update Claude Code. Run manually: claude update"
fi

# --- Install required Claude Code plugins ---

_install_plugin() {
  local plugin="$1"
  local name="${plugin%%@*}"
  if claude plugin list 2>/dev/null | grep -q "^  . ${name}"; then
    echo "Updating ${name} plugin..."
    claude plugin update "$name" --scope user 2>/dev/null \
      && echo "${name} plugin updated." \
      || echo "Warning: Failed to update ${name}. Run manually: claude plugin update ${name}"
  else
    echo "Installing ${name} plugin..."
    claude plugin install "$plugin" --scope user 2>/dev/null \
      && echo "${name} plugin installed." \
      || echo "Warning: Failed to install ${name}. Run manually: claude plugin install ${plugin}"
  fi
}

_install_plugin "document-skills@anthropic-agent-skills"
_install_plugin "context7@claude-plugins-official"
_install_plugin "frontend-design@claude-plugins-official"

# --- Deploy to target directory ---

export VISTA_FORCE

echo "Deploying common templates..."
bash "$VISTA_HOME/scripts/copy-common.sh" "$TARGET_DIR"
