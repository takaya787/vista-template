#!/bin/bash
# Entry point for com.vista.plist-ledger-sync-checker
# Called by LaunchAgent — does not inherit login shell PATH or venv.

set -euo pipefail

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Resolve working_dir from script location (scripts/plist-ledger-sync-checker/ → working_dir)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKING_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "$WORKING_DIR"

# Bootstrap venv if not yet initialized (self-healing for infrastructure scripts)
if [ ! -f "tmp/venv/bin/activate" ]; then
  python3 -m venv tmp/venv
fi

source tmp/venv/bin/activate

exec python "${SCRIPT_DIR}/main.py" "$@"
