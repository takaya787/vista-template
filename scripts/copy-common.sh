#!/bin/bash
set -euo pipefail

# Copy common templates to a target directory
# Usage: ./scripts/copy-common.sh <target-directory>

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$ROOT_DIR/templates"
COMMON_DIR="$TEMPLATES_DIR/common"

# --- Usage ---

if [ $# -lt 1 ]; then
  echo "Usage: $0 <target-directory>"
  echo ""
  echo "Copies templates/common/ contents to the specified directory."
  echo ""
  echo "Example:"
  echo "  $0 ~/projects/my-project"
  exit 1
fi

TARGET_DIR="$1"

# --- Validation ---

if [ ! -d "$COMMON_DIR" ]; then
  echo "Error: Common template directory not found at $COMMON_DIR"
  exit 1
fi

# --- Target directory check ---

if [ -d "$TARGET_DIR/.claude" ] || [ -f "$TARGET_DIR/CLAUDE.md" ]; then
  echo "Warning: Target directory already contains Claude Code configuration."
  read -p "Overwrite existing files? (y/N): " CONFIRM < /dev/tty
  if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Aborted."
    exit 0
  fi
fi

# --- Copy ---

echo "Copying common templates to $TARGET_DIR..."
mkdir -p "$TARGET_DIR"
cp -R "$COMMON_DIR/." "$TARGET_DIR/"

# Make hook scripts executable
if [ -d "$TARGET_DIR/.claude/hooks" ]; then
  chmod +x "$TARGET_DIR/.claude/hooks/"*.sh 2>/dev/null || true
fi

echo "Done!"
echo ""
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Review and customize files as needed"
echo "  3. Start Claude Code: claude"
