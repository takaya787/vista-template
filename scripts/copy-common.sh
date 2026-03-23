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

FORCE="${VISTA_FORCE:-true}"

if _has_non_symlink_config "$TARGET_DIR"; then
  if [ "$FORCE" = "true" ]; then
    echo "Overwriting existing Claude Code configuration (VISTA_FORCE=true)..."
  else
    echo "Warning: Target directory already contains Claude Code configuration (non-symlink files)."
    read -p "Overwrite existing files? (y/N): " CONFIRM < /dev/tty
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
      echo "Aborted."
      exit 0
    fi
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
mkdir -p "$TARGET_DIR/memory" "$TARGET_DIR/minutes"

# 2. convention files → symlink (absolute path)
for f in "$COMMON_DIR/.claude/rules/convention/"*.md; do
  [ -e "$f" ] || continue
  ln -sf "$f" "$TARGET_DIR/.claude/rules/convention/$(basename "$f")"
done

# 3. skills → symlink (per skill directory, overwrite if same name exists)
for skill_dir in "$COMMON_DIR/.claude/skills/"*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  target_skill="$TARGET_DIR/.claude/skills/$skill_name"
  # Remove existing skill (symlink or directory) before creating symlink
  [ -e "$target_skill" ] || [ -L "$target_skill" ] && rm -rf "$target_skill"
  ln -sf "$skill_dir" "$target_skill"
done

# 4. hooks → copy (symlinks are a security risk for hooks)
cp "$COMMON_DIR/.claude/hooks/"*.sh "$TARGET_DIR/.claude/hooks/" 2>/dev/null || true

# 5. config → copy (only if not already present, project-specific content)
for f in "$COMMON_DIR/.claude/rules/config/"*.md; do
  [ -e "$f" ] || continue
  target_file="$TARGET_DIR/.claude/rules/config/$(basename "$f")"
  [ -e "$target_file" ] && continue
  cp "$f" "$target_file"
done

# 6. authority.md → symlink (absolute path)
ln -sf "$COMMON_DIR/.claude/rules/authority.md" "$TARGET_DIR/.claude/rules/authority.md" 2>/dev/null || true

# 7. memory/MEMORY.md → copy (only if not already present, project-specific)
if [ ! -f "$TARGET_DIR/memory/MEMORY.md" ]; then
  cp "$COMMON_DIR/memory/MEMORY.md" "$TARGET_DIR/memory/" 2>/dev/null || true
fi

# 8. settings.local.json → copy from sample (only if not already present)
if [ ! -f "$TARGET_DIR/.claude/settings.local.json" ]; then
  cp "$COMMON_DIR/.claude/settings.local.sample.json" "$TARGET_DIR/.claude/settings.local.json" 2>/dev/null || true
fi

# 9. .gitignore → copy sample if absent, append if already present (skip if .vista already included)
if [ -f "$COMMON_DIR/.gitignore.sample" ]; then
  if [ ! -f "$TARGET_DIR/.gitignore" ]; then
    cp "$COMMON_DIR/.gitignore.sample" "$TARGET_DIR/.gitignore"
  elif ! grep -q '\.vista' "$TARGET_DIR/.gitignore"; then
    echo "" >> "$TARGET_DIR/.gitignore"
    cat "$COMMON_DIR/.gitignore.sample" >> "$TARGET_DIR/.gitignore"
  fi
fi

# 10. docs scaffold → copy (only files not already present)
if [ -d "$COMMON_DIR/docs" ]; then
  find "$COMMON_DIR/docs" -type f | while read -r f; do
    rel="${f#$COMMON_DIR/docs/}"
    target_file="$TARGET_DIR/docs/$rel"
    [ -e "$target_file" ] && continue
    mkdir -p "$(dirname "$target_file")"
    cp "$f" "$target_file"
  done
fi

# Make hook scripts executable (explicit filenames only, no glob)
chmod +x \
  "$TARGET_DIR/.claude/hooks/audit-command.sh" \
  "$TARGET_DIR/.claude/hooks/audit-file-write.sh" \
  "$TARGET_DIR/.claude/hooks/block-dangerous-commands.sh" \
  "$TARGET_DIR/.claude/hooks/block-ssrf.sh" \
  2>/dev/null || true

# --- Generate .vista/ state & profile ---

echo "Creating .vista/ state and profile..."

# Auto-detect GitHub username
GITHUB_USER=""
if command -v gh &> /dev/null; then
  GITHUB_USER=$(gh api user --jq '.login' 2>/dev/null || echo "")
fi

# Auto-detect timezone
TIMEZONE=""
if command -v python3 &> /dev/null; then
  TIMEZONE=$(python3 -c "import datetime; print(datetime.datetime.now().astimezone().tzinfo)" 2>/dev/null || echo "")
fi

SETUP_DATE=$(date +%Y-%m-%d)
CREATED_AT=$(date -u +%Y-%m-%dT%H:%M:%S%z 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)

# Generate .vista/state/setup.json
cat > "$TARGET_DIR/.vista/state/setup.json" << EOF
{
  "setupDate": "$SETUP_DATE",
  "sourceVersion": "1.0.0"
}
EOF

# --- Global profile: ~/.vista/profile/me.json ---
# Onboarding results are stored once in the global location.
# Each project's .vista/profile/me.json is a symlink to it.

GLOBAL_PROFILE_DIR="$HOME/.vista/profile"
mkdir -p "$GLOBAL_PROFILE_DIR"

# Write skeleton to global profile only if it does not already exist
if [ ! -f "$GLOBAL_PROFILE_DIR/me.json" ]; then
  cat > "$GLOBAL_PROFILE_DIR/me.json" << EOF
{
  "isOnboardingCompleted": false,
  "name": "",
  "email": "",
  "preferences": {
    "language": "ja",
    "outputFormat": "",
    "verbosity": "",
    "tone": ""
  },
  "role": {
    "category": "",
    "title": "",
    "industry": "",
    "companySize": ""
  },
  "work": {
    "primaryOutputs": []
  },
  "workingStyle": {
    "timezone": "${TIMEZONE}",
    "autonomy": "",
    "editScope": "",
    "neverDo": "",
    "alwaysFollow": ""
  },
  "services": {
    "communication": [],
    "projectManagement": [],
    "otherTools": ""
  },
  "documentation": {
    "tools": []
  },
  "goals": {
    "primaryUseCases": [],
    "painPoint": ""
  }
}
EOF
  echo "Created global profile at $GLOBAL_PROFILE_DIR/me.json"
else
  echo "Global profile already exists at $GLOBAL_PROFILE_DIR/me.json — reusing"
fi

# Project .vista/profile/me.json → symlink to global profile
ln -sf "$GLOBAL_PROFILE_DIR/me.json" "$TARGET_DIR/.vista/profile/me.json"

# Project .vista/profile/project.json → skeleton (per-project, never symlink)
if [ ! -f "$TARGET_DIR/.vista/profile/project.json" ]; then
  cat > "$TARGET_DIR/.vista/profile/project.json" << EOF
{
  "isOnboardingCompleted": false,
  "company": {
    "name": "",
    "industry": "",
    "description": ""
  },
  "myWork": {
    "domain": "",
    "products": "",
    "recurringTasks": "",
    "keyMetrics": ""
  },
  "stakeholders": {
    "internal": "",
    "external": ""
  },
  "currentInitiatives": "",
  "businessTerms": "",
  "constraints": "",
  "neverDo": "",
  "references": []
}
EOF
  echo "Created project profile skeleton at $TARGET_DIR/.vista/profile/project.json"
fi

# Generate .vista/state/onboarding.json:
# - pending  if global profile is a skeleton (onboarding not yet completed)
# - active   if global profile already has name filled in (onboarding done previously)
if [ ! -f "$TARGET_DIR/.vista/state/onboarding.json" ]; then
  IS_COMPLETE=$(python3 -c "
import json
try:
  d = json.load(open('$GLOBAL_PROFILE_DIR/me.json'))
  print('true' if d.get('isOnboardingCompleted') else 'false')
except Exception:
  print('false')
" 2>/dev/null || echo "false")

  if [ "$IS_COMPLETE" = "true" ]; then
    ONBOARDING_STATUS="active"
  else
    ONBOARDING_STATUS="pending"
  fi

  cat > "$TARGET_DIR/.vista/state/onboarding.json" << EOF
{
  "status": "${ONBOARDING_STATUS}",
  "createdAt": "$CREATED_AT"
}
EOF
fi

echo "Done!"
echo ""
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Start Claude Code: claude"
echo "     (On first launch, /onboarding will guide you through task-based setup)"
