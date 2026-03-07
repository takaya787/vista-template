#!/bin/bash
set -euo pipefail

# Vista Template Setup Script
# Usage: ./scripts/setup.sh <role> <target-directory>
#
# Interactive setup that configures everything in one pass:
#   1. Project settings (role-specific: GitHub, Notion, etc.)
#   2. User profile (me.json)
#   3. File copy & placeholder replacement
#   4. Environment setup (npm install, etc.)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$ROOT_DIR/templates"

AVAILABLE_ROLES=(
  "scrum-master"
  "product-manager"
  "designer"
  "engineer"
  "marketing"
  "investor-relations"
)

# --- Helpers ---

prompt_required() {
  local label="$1"
  local var_name="$2"
  local value=""
  while [ -z "$value" ]; do
    read -p "$label: " value
    if [ -z "$value" ]; then
      echo "  This field is required."
    fi
  done
  eval "$var_name=\"\$value\""
}

prompt_optional() {
  local label="$1"
  local var_name="$2"
  local default="${3:-}"
  if [ -n "$default" ]; then
    read -p "$label [$default]: " value
    value="${value:-$default}"
  else
    read -p "$label (skip: Enter): " value
  fi
  eval "$var_name=\"\$value\""
}

prompt_csv() {
  local label="$1"
  local var_name="$2"
  local default="${3:-}"
  if [ -n "$default" ]; then
    read -p "$label [$default]: " value
    value="${value:-$default}"
  else
    read -p "$label (comma-separated, skip: Enter): " value
  fi
  eval "$var_name=\"\$value\""
}

# Convert comma-separated string to JSON array
csv_to_json_array() {
  local csv="$1"
  if [ -z "$csv" ]; then
    echo "[]"
    return
  fi
  local result="["
  local first=true
  IFS=',' read -ra items <<< "$csv"
  for item in "${items[@]}"; do
    item="$(echo "$item" | xargs)" # trim whitespace
    if [ -n "$item" ]; then
      if [ "$first" = true ]; then
        first=false
      else
        result+=", "
      fi
      result+="\"$item\""
    fi
  done
  result+="]"
  echo "$result"
}

# Escape string for sed replacement (handle / and &)
sed_escape() {
  echo "$1" | sed -e 's/[\/&]/\\&/g'
}

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
  echo "  $0 engineer ./my-app"
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
  echo "Currently only 'scrum-master' is ready."
  exit 1
fi

if [ ! -d "$COMMON_DIR" ]; then
  echo "Error: Common template directory not found at $COMMON_DIR"
  exit 1
fi

# --- Target directory check ---

if [ -d "$TARGET_DIR/.claude" ] || [ -f "$TARGET_DIR/CLAUDE.md" ]; then
  echo "Warning: Target directory already contains Claude Code configuration."
  read -p "Overwrite existing files? (y/N): " CONFIRM
  if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Aborted."
    exit 0
  fi
fi

# ============================================================
# Phase 1: Project Settings (role-specific)
# ============================================================

echo ""
echo "=== Vista Template Setup ==="
echo "Role: $ROLE"
echo "Target: $TARGET_DIR"
echo ""

# -- Role-specific config collection --

# Variables for scrum-master
GH_ORG=""
GH_PROJECT_NAME=""
GH_PROJECT_NUMBER=""
GH_ISSUE_REPO=""
GH_OUTPUT_REPOS=""
NOTION_PAGE_NAME=""
NOTION_PAGE_URL=""

if [ "$ROLE" = "scrum-master" ]; then
  echo "--- Project Settings (GitHub) ---"
  prompt_required "GitHub Organization" GH_ORG
  prompt_required "GitHub Project name" GH_PROJECT_NAME
  prompt_required "GitHub Project number (for GraphQL)" GH_PROJECT_NUMBER
  prompt_required "Issue tracking repository name" GH_ISSUE_REPO
  prompt_optional "Output repositories (comma-separated)" GH_OUTPUT_REPOS
  echo ""

  echo "--- Project Settings (Notion) ---"
  prompt_optional "Notion page name" NOTION_PAGE_NAME
  if [ -n "$NOTION_PAGE_NAME" ]; then
    prompt_required "Notion page URL" NOTION_PAGE_URL
  fi
  echo ""
fi

# ============================================================
# Phase 2: User Profile (me.json)
# ============================================================

echo "--- User Profile ---"

# Try to auto-detect GitHub username
GH_USER_DEFAULT=""
if command -v gh &> /dev/null; then
  GH_USER_DEFAULT="$(gh api user --jq '.login' 2>/dev/null || true)"
fi

prompt_required "Your name" ME_NAME
prompt_optional "GitHub username" ME_GITHUB "$GH_USER_DEFAULT"
prompt_optional "Email" ME_EMAIL
prompt_optional "Slack ID" ME_SLACK_ID

# Role-based default position
case "$ROLE" in
  scrum-master)     DEFAULT_POSITION="Scrum Master" ;;
  product-manager)  DEFAULT_POSITION="Product Manager" ;;
  designer)         DEFAULT_POSITION="Designer" ;;
  engineer)         DEFAULT_POSITION="Software Engineer" ;;
  marketing)        DEFAULT_POSITION="Marketing" ;;
  investor-relations) DEFAULT_POSITION="Investor Relations" ;;
  *)                DEFAULT_POSITION="" ;;
esac

prompt_optional "Position" ME_POSITION "$DEFAULT_POSITION"
prompt_optional "Team" ME_TEAM
prompt_optional "Role (e.g., member, lead)" ME_ROLE "member"
prompt_csv "Tech stack" ME_TECH_STACK
prompt_csv "Focus areas" ME_FOCUS_AREAS

# Timezone auto-detect
if command -v python3 &> /dev/null; then
  TZ_DEFAULT="$(python3 -c 'import datetime; print(datetime.datetime.now().astimezone().tzinfo)' 2>/dev/null || echo "Asia/Tokyo")"
else
  TZ_DEFAULT="Asia/Tokyo"
fi
prompt_optional "Timezone" ME_TIMEZONE "$TZ_DEFAULT"
prompt_optional "Working hours" ME_WORKING_HOURS "10:00-19:00"
prompt_optional "Output language (ja/en)" ME_LANGUAGE "ja"
echo ""

# ============================================================
# Phase 3: Confirmation
# ============================================================

echo "=== Configuration Summary ==="
echo ""

if [ "$ROLE" = "scrum-master" ]; then
  echo "[Project]"
  echo "  GitHub Org:        $GH_ORG"
  echo "  Project:           $GH_PROJECT_NAME (#$GH_PROJECT_NUMBER)"
  echo "  Issue Repo:        $GH_ORG/$GH_ISSUE_REPO"
  [ -n "$GH_OUTPUT_REPOS" ] && echo "  Output Repos:      $GH_OUTPUT_REPOS"
  [ -n "$NOTION_PAGE_NAME" ] && echo "  Notion:            $NOTION_PAGE_NAME -> $NOTION_PAGE_URL"
  echo ""
fi

echo "[Profile]"
echo "  Name:              $ME_NAME"
echo "  GitHub:            $ME_GITHUB"
[ -n "$ME_EMAIL" ] && echo "  Email:             $ME_EMAIL"
[ -n "$ME_SLACK_ID" ] && echo "  Slack ID:          $ME_SLACK_ID"
echo "  Position:          $ME_POSITION"
[ -n "$ME_TEAM" ] && echo "  Team:              $ME_TEAM"
echo "  Role:              $ME_ROLE"
[ -n "$ME_TECH_STACK" ] && echo "  Tech Stack:        $ME_TECH_STACK"
[ -n "$ME_FOCUS_AREAS" ] && echo "  Focus Areas:       $ME_FOCUS_AREAS"
echo "  Timezone:          $ME_TIMEZONE"
echo "  Working Hours:     $ME_WORKING_HOURS"
echo "  Language:          $ME_LANGUAGE"
echo ""

read -p "Proceed with setup? (Y/n): " CONFIRM
if [ "$CONFIRM" = "n" ] || [ "$CONFIRM" = "N" ]; then
  echo "Aborted."
  exit 0
fi

# ============================================================
# Phase 4: Copy Template Files
# ============================================================

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

# ============================================================
# Phase 5: Replace Placeholders
# ============================================================

echo "  Applying configuration..."

if [ "$ROLE" = "scrum-master" ]; then
  GH_WORKFLOW="$TARGET_DIR/.claude/rules/config/github-workflow.md"
  if [ -f "$GH_WORKFLOW" ]; then
    sed -i '' "s/{{ORG_NAME}}/$(sed_escape "$GH_ORG")/g" "$GH_WORKFLOW"
    sed -i '' "s/{{PROJECT_NAME}}/$(sed_escape "$GH_PROJECT_NAME")/g" "$GH_WORKFLOW"
    sed -i '' "s/{{PROJECT_NUMBER}}/$(sed_escape "$GH_PROJECT_NUMBER")/g" "$GH_WORKFLOW"
    sed -i '' "s/{{ISSUE_REPO}}/$(sed_escape "$GH_ISSUE_REPO")/g" "$GH_WORKFLOW"
    if [ -n "$GH_OUTPUT_REPOS" ]; then
      sed -i '' "s/{{OUTPUT_REPOS}}/$(sed_escape "$GH_OUTPUT_REPOS")/g" "$GH_WORKFLOW"
    else
      sed -i '' "s/{{OUTPUT_REPOS}}/(none)/g" "$GH_WORKFLOW"
    fi
  fi

  NOTION_CONF="$TARGET_DIR/.claude/rules/config/notion-pages.md"
  if [ -f "$NOTION_CONF" ]; then
    if [ -n "$NOTION_PAGE_NAME" ]; then
      sed -i '' "s/{{PAGE_NAME}}/$(sed_escape "$NOTION_PAGE_NAME")/g" "$NOTION_CONF"
      sed -i '' "s|{{NOTION_PAGE_URL}}|$(sed_escape "$NOTION_PAGE_URL")|g" "$NOTION_CONF"
    else
      # Remove placeholder row if Notion is not configured
      sed -i '' '/{{PAGE_NAME}}/d' "$NOTION_CONF"
    fi
  fi
fi

# Add team member to docs/team.md
TEAM_MD="$TARGET_DIR/docs/team.md"
if [ -f "$TEAM_MD" ]; then
  TEAM_ENTRY="| $ME_NAME | $ME_GITHUB | $ME_ROLE | ${ME_TEAM:-—} |"
  sed -i '' "s/| <!-- Add team members here --> | | | |/$TEAM_ENTRY/" "$TEAM_MD"
fi

# ============================================================
# Phase 6: Generate me.json
# ============================================================

echo "  Creating me.json..."

TECH_STACK_JSON="$(csv_to_json_array "$ME_TECH_STACK")"
FOCUS_AREAS_JSON="$(csv_to_json_array "$ME_FOCUS_AREAS")"

cat > "$TARGET_DIR/me.json" << MEJSON
{
  "name": "$ME_NAME",
  "github": "$ME_GITHUB",
  "email": "${ME_EMAIL}",
  "slackId": "${ME_SLACK_ID}",
  "position": "$ME_POSITION",
  "team": "${ME_TEAM}",
  "role": "$ME_ROLE",
  "techStack": $TECH_STACK_JSON,
  "focusAreas": $FOCUS_AREAS_JSON,
  "workingStyle": {
    "timezone": "$ME_TIMEZONE",
    "workingHours": "$ME_WORKING_HOURS",
    "communication": "Slack async-first"
  },
  "preferences": {
    "language": "$ME_LANGUAGE",
    "outputFormat": "Concise bullet points"
  },
  "legalNotice": "This data is used locally only and is never sent to remote servers"
}
MEJSON

# ============================================================
# Phase 7: Environment Setup
# ============================================================

if [ -f "$TARGET_DIR/package.json" ]; then
  echo "  Installing dependencies..."
  (cd "$TARGET_DIR" && pnpm install --silent 2>/dev/null) || {
    echo "  Warning: pnpm install failed. Run it manually: cd $TARGET_DIR && pnpm install"
  }
fi

# ============================================================
# Done
# ============================================================

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Review .claude/rules/config/ files if you need to adjust settings"
echo "  3. Start Claude Code: claude"
echo ""
