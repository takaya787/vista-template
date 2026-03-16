#!/bin/bash
set -euo pipefail

# Vista Template Setup Script
# Usage: ./scripts/setup.sh <role> <target-directory>
#
# Copies common + role-specific template files to the target directory.
# Profile personalization is handled by the /onboarding skill on first Claude Code launch.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$ROOT_DIR/templates"

AVAILABLE_ROLES=(
  "scrum-master"
  "product-manager"
  "designer"
  "marketing"
  "investor-relations"
)

usage() {
  echo "Vista Template Setup"
  echo ""
  echo "Usage: $0 <role> <target-directory>"
  echo ""
  echo "Available roles:"
  for role in "${AVAILABLE_ROLES[@]}"; do
    if [ -f "$TEMPLATES_DIR/$role/CLAUDE.md" ]; then
      echo "  $role (ready)"
    else
      echo "  $role (coming soon)"
    fi
  done
  echo ""
  echo "Examples:"
  echo "  $0 scrum-master ~/projects/my-project"
  echo "  $0 designer ./my-app"
}

# --- Argument validation ---

if [ $# -lt 2 ]; then
  usage
  exit 1
fi

ROLE="$1"
TARGET_DIR="$2"

# Validate role
ROLE_VALID=false
for r in "${AVAILABLE_ROLES[@]}"; do
  if [ "$r" = "$ROLE" ]; then
    ROLE_VALID=true
    break
  fi
done

if [ "$ROLE_VALID" = false ]; then
  echo "Error: Unknown role '$ROLE'"
  echo ""
  usage
  exit 1
fi

COMMON_DIR="$TEMPLATES_DIR/common"
ROLE_DIR="$TEMPLATES_DIR/$ROLE"

if [ ! -f "$ROLE_DIR/CLAUDE.md" ]; then
  echo "Error: Template for '$ROLE' is not yet available."
  exit 1
fi

if [ ! -d "$COMMON_DIR" ]; then
  echo "Error: Common template directory not found at $COMMON_DIR"
  exit 1
fi

# --- Target directory check ---

FORCE="${VISTA_FORCE:-true}"

if [ -d "$TARGET_DIR/.claude" ] || [ -f "$TARGET_DIR/CLAUDE.md" ]; then
  if [ "$FORCE" = "true" ]; then
    echo "Overwriting existing Claude Code configuration (VISTA_FORCE=true)..."
  else
    echo "Warning: Target directory already contains Claude Code configuration."
    read -p "Overwrite existing files? (y/N): " CONFIRM < /dev/tty
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
      echo "Aborted."
      exit 0
    fi
  fi
fi

# --- Copy Template Files ---

echo ""
echo "Setting up '$ROLE' template in $TARGET_DIR..."

mkdir -p "$TARGET_DIR"

# Step 1: Copy common files
echo "  Copying common files..."
cp -R "$COMMON_DIR/." "$TARGET_DIR/"

# Step 2: Copy role-specific files (overwrites common where needed)
echo "  Copying $ROLE-specific files..."
cp -R "$ROLE_DIR/." "$TARGET_DIR/"

# Make hook scripts executable
if [ -d "$TARGET_DIR/.claude/hooks" ]; then
  chmod +x "$TARGET_DIR/.claude/hooks/"*.sh 2>/dev/null || true
fi

# --- Generate .vista/ structure ---

echo "  Creating .vista/ directory structure..."

mkdir -p "$TARGET_DIR/.vista/state"
mkdir -p "$TARGET_DIR/.vista/profile"
mkdir -p "$TARGET_DIR/.vista/config"

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

# Generate .vista/state/setup.json
SETUP_DATE=$(date +%Y-%m-%d)
cat > "$TARGET_DIR/.vista/state/setup.json" << EOF
{
  "role": "$ROLE",
  "setupDate": "$SETUP_DATE",
  "sourceVersion": "1.0.0"
}
EOF

# Generate .vista/profile/me.json (skeleton)
cat > "$TARGET_DIR/.vista/profile/me.json" << EOF
{
  "github": "${GITHUB_USER}",
  "workingStyle": { "timezone": "${TIMEZONE}" },
  "preferences": { "language": "ja" },
  "legalNotice": "This data is used locally only and is never sent to remote servers"
}
EOF

# Generate .vista/state/onboarding.json (pending)
CREATED_AT=$(date -u +%Y-%m-%dT%H:%M:%S%z 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)
cat > "$TARGET_DIR/.vista/state/onboarding.json" << EOF
{
  "status": "pending",
  "createdAt": "$CREATED_AT"
}
EOF

# --- Install dependencies ---

cd "$TARGET_DIR"
echo "  Installing dependencies with pnpm..."
pnpm install

# --- Done ---

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Start Claude Code: claude"
echo "     (On first launch, /onboarding will personalize your profile and settings)"
echo ""
