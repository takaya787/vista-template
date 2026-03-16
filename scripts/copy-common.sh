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

# Check if any existing files are not symlinks (skip if all are symlinks or directory is new)
_has_non_symlink_config() {
  local dir="$1"
  [ -d "$dir/.claude" ] || [ -f "$dir/CLAUDE.md" ] || return 1
  # If convention files exist and are NOT symlinks, prompt
  for f in "$dir/.claude/rules/convention/"*.md "$dir/.claude/rules/authority.md"; do
    [ -e "$f" ] || continue
    [ -L "$f" ] || return 0
  done
  return 1
}

if _has_non_symlink_config "$TARGET_DIR"; then
  echo "Warning: Target directory already contains Claude Code configuration (non-symlink files)."
  read -p "Overwrite existing files? (y/N): " CONFIRM < /dev/tty
  if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Aborted."
    exit 0
  fi
fi

# --- Deploy ---

echo "Deploying common templates to $TARGET_DIR..."
mkdir -p "$TARGET_DIR"

# 1. Directory skeleton
mkdir -p "$TARGET_DIR/.claude/rules/convention"
mkdir -p "$TARGET_DIR/.claude/rules/config"
mkdir -p "$TARGET_DIR/.claude/hooks"
mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/.ai/plans" "$TARGET_DIR/.ai/tasks" "$TARGET_DIR/.ai/audit"
mkdir -p "$TARGET_DIR/.vista/state" "$TARGET_DIR/.vista/profile"
mkdir -p "$TARGET_DIR/memory" "$TARGET_DIR/docs/members" "$TARGET_DIR/minutes" "$TARGET_DIR/screenshots"

# 2. convention files → symlink (absolute path)
for f in "$COMMON_DIR/.claude/rules/convention/"*.md; do
  [ -e "$f" ] || continue
  ln -sf "$f" "$TARGET_DIR/.claude/rules/convention/$(basename "$f")"
done

# 3. skills → copy (subdirectories included)
cp -R "$COMMON_DIR/.claude/skills/." "$TARGET_DIR/.claude/skills/" 2>/dev/null || true

# 4. hooks → copy (symlinks are a security risk for hooks)
cp "$COMMON_DIR/.claude/hooks/"*.sh "$TARGET_DIR/.claude/hooks/" 2>/dev/null || true

# 5. config → copy (project-specific content)
cp "$COMMON_DIR/.claude/rules/config/"*.md "$TARGET_DIR/.claude/rules/config/" 2>/dev/null || true

# 6. authority.md → symlink (absolute path)
ln -sf "$COMMON_DIR/.claude/rules/authority.md" "$TARGET_DIR/.claude/rules/authority.md" 2>/dev/null || true

# 7. memory/MEMORY.md → copy (project-specific)
cp "$COMMON_DIR/memory/MEMORY.md" "$TARGET_DIR/memory/" 2>/dev/null || true

# 8. settings.local.json → copy from sample (only if not already present)
if [ ! -f "$TARGET_DIR/.claude/settings.local.json" ]; then
  cp "$COMMON_DIR/.claude/settings.local.sample.json" "$TARGET_DIR/.claude/settings.local.json" 2>/dev/null || true
fi

# 9. .gitignore → copy sample if absent, append if already present
if [ -f "$COMMON_DIR/.gitignore.sample" ]; then
  if [ ! -f "$TARGET_DIR/.gitignore" ]; then
    cp "$COMMON_DIR/.gitignore.sample" "$TARGET_DIR/.gitignore"
  else
    echo "" >> "$TARGET_DIR/.gitignore"
    cat "$COMMON_DIR/.gitignore.sample" >> "$TARGET_DIR/.gitignore"
  fi
fi

# 10. docs scaffold → copy
cp -R "$COMMON_DIR/docs/." "$TARGET_DIR/docs/" 2>/dev/null || true

# Make hook scripts executable (explicit filenames only, no glob)
chmod +x \
  "$TARGET_DIR/.claude/hooks/audit-command.sh" \
  "$TARGET_DIR/.claude/hooks/audit-file-write.sh" \
  "$TARGET_DIR/.claude/hooks/block-dangerous-commands.sh" \
  "$TARGET_DIR/.claude/hooks/block-ssrf.sh" \
  "$TARGET_DIR/.claude/hooks/notify.sh" \
  2>/dev/null || true

echo "Done!"
echo ""
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Review and customize files as needed"
echo "  3. Start Claude Code: claude"
