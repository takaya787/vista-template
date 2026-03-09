#!/bin/bash
set -euo pipefail

# Vista Template Installer (curl-friendly)
# Downloads and runs setup without requiring git clone.
#
# Full Setup (role-specific):
#   curl -fsSL https://raw.githubusercontent.com/takaya787/vista-template/main/scripts/install.sh | bash -s -- <role> <target>
#
# Quick Use (common only):
#   curl -fsSL https://raw.githubusercontent.com/takaya787/vista-template/main/scripts/install.sh | bash -s -- <target>

REPO_TARBALL="https://github.com/takaya787/vista-template/archive/refs/heads/main.tar.gz"
EXTRACTED_DIR_NAME="vista-template-main"

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
}

# --- Argument parsing ---

ROLE=""
TARGET_DIR=""

if [ $# -ge 2 ]; then
  # Full Setup: role + target
  ROLE="$1"
  TARGET_DIR="$2"
elif [ $# -eq 1 ]; then
  # Quick Use: target only
  TARGET_DIR="$1"
else
  usage
  exit 1
fi

# --- Temporary directory with cleanup ---

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# --- Download and extract ---

echo "Downloading vista-template..."
curl -fsSL "$REPO_TARBALL" | tar -xz -C "$TMPDIR"

REPO_DIR="$TMPDIR/$EXTRACTED_DIR_NAME"

if [ ! -d "$REPO_DIR" ]; then
  echo "Error: Failed to extract repository."
  exit 1
fi

# --- Run the appropriate script ---

if [ -n "$ROLE" ]; then
  echo "Running Full Setup (role: $ROLE)..."
  bash "$REPO_DIR/scripts/setup.sh" "$ROLE" "$TARGET_DIR"
else
  echo "Running Quick Use (common only)..."
  bash "$REPO_DIR/scripts/copy-common.sh" "$TARGET_DIR"
fi
