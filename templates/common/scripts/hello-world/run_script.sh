#!/bin/bash
# Entry point for com.vista.hello-world
# Called by LaunchAgent — does not inherit login shell PATH or venv.

set -euo pipefail

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Resolve working_dir from script location (scripts/hello-world/ → working_dir)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKING_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "$WORKING_DIR"

# Activate venv
source tmp/venv/bin/activate

# Execute
exec python "${SCRIPT_DIR}/main.py" "$@"
