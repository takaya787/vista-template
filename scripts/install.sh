#!/bin/bash
set -euo pipefail

# Vista Template Installer (curl-friendly)
# Downloads vista-template to ~/.vista/vista-template (persistent) and deploys to a target directory.
#
# Full Setup (role-specific):
#   curl -fsSL https://raw.githubusercontent.com/takaya787/vista-template/main/scripts/install.sh | bash -s -- <role> <target>
#
# Quick Use (common only):
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
  echo "  install.sh <role> <target-directory>   # Full Setup (role-specific)"
  echo "  install.sh <target-directory>           # Quick Use (common only)"
  echo ""
  echo "Examples:"
  echo "  curl -fsSL .../install.sh | bash -s -- scrum-master ~/my-project"
  echo "  curl -fsSL .../install.sh | bash -s -- ~/my-project"
  echo ""
  echo "Environment:"
  echo "  VISTA_HOME    Override install path (default: ~/.vista/vista-template)"
  echo "  VISTA_FORCE   Skip confirmation prompts (default: false)"
}

# --- Argument parsing ---

ROLE=""
TARGET_DIR=""

if [ $# -ge 2 ]; then
  ROLE="$1"
  TARGET_DIR="$2"
elif [ $# -eq 1 ]; then
  TARGET_DIR="$1"
else
  usage
  exit 1
fi

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
  echo "Claude Code already installed: $(claude --version)"
fi

# --- Deploy to target directory ---

export VISTA_FORCE

if [ -n "$ROLE" ]; then
  echo "Running Full Setup (role: $ROLE)..."
  bash "$VISTA_HOME/scripts/setup.sh" "$ROLE" "$TARGET_DIR"
else
  echo "Running Quick Use (common only)..."
  bash "$VISTA_HOME/scripts/copy-common.sh" "$TARGET_DIR"
fi
