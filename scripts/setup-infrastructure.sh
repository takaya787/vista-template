#!/bin/bash
set -euo pipefail

# Set up infrastructure LaunchAgents for a Vista workspace.
# Must be run after copy-common.sh has deployed scripts to the target directory.
#
# Usage: ./scripts/setup-infrastructure.sh <target-directory>

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <target-directory>"
  echo ""
  echo "Sets up infrastructure LaunchAgents (venv init + plist registration)."
  echo "Run after copy-common.sh."
  exit 1
fi

TARGET_DIR="$(cd "$1" && pwd)"

# ---------------------------------------------------------------------------
# Initialize Python venv
# ---------------------------------------------------------------------------

echo "--- Python venv ---"
if command -v python3 &> /dev/null; then
  if [ ! -f "$TARGET_DIR/tmp/venv/bin/activate" ]; then
    echo "Initializing Python venv at $TARGET_DIR/tmp/venv ..."
    python3 -m venv "$TARGET_DIR/tmp/venv"
    echo "venv initialized"
  else
    echo "venv already exists, skipping"
  fi
else
  echo "Warning: python3 not found. venv not initialized — run 'python3 -m venv tmp/venv' manually."
fi

# ---------------------------------------------------------------------------
# Register infrastructure LaunchAgents
# ---------------------------------------------------------------------------

if ! command -v launchctl &> /dev/null; then
  echo "Note: launchctl not found (non-macOS). Skipping LaunchAgent registration."
  exit 0
fi

_USER_ID="$(id -u)"

# Register a single infrastructure LaunchAgent.
# Arguments:
#   $1  label          e.g. com.vista.plist-ledger-sync-checker
#   $2  script_path    absolute path to run_script.sh
#   $3  schedule_key   StartCalendarInterval | StartInterval
#   $4  schedule_value XML dict string (for StartCalendarInterval) or integer seconds (for StartInterval)
#   $5  description    human-readable description (Japanese OK)
#   $6  cron           cron expression e.g. "0 * * * *"
#   $7  schedule_human e.g. "毎時 :00"
_register() {
  local label="$1"
  local script_path="$2"
  local schedule_key="$3"
  local schedule_value="$4"
  local description="$5"
  local cron="$6"
  local schedule_human="$7"
  local plist_dest="$HOME/Library/LaunchAgents/$label.plist"
  local plist_tmp="/tmp/$label.plist"

  echo ""
  echo "--- Registering $label ---"

  if [ ! -f "$script_path" ]; then
    echo "Warning: $script_path not found. Skipping."
    return
  fi

  chmod +x "$script_path"

  cat > "$plist_tmp" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$script_path</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$TARGET_DIR</string>
  <key>$schedule_key</key>
  $schedule_value
  <key>StandardOutPath</key>
  <string>/tmp/$label.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/$label-error.log</string>
</dict>
</plist>
EOF

  cp "$plist_tmp" "$plist_dest"

  # Re-bootstrap safely (bootout first to handle re-runs)
  launchctl bootout "gui/$_USER_ID/$label" 2>/dev/null || true
  launchctl bootstrap "gui/$_USER_ID" "$plist_dest" \
    && echo "Registered: $label ($schedule_human)" \
    || echo "Warning: launchctl bootstrap failed for $label"

  # Update automation-library.json and vista-official-plists.json
  python3 - "$TARGET_DIR" "$label" "$script_path" "$description" "$cron" "$schedule_human" << 'PYEOF'
import json, sys
from datetime import datetime, timezone
from pathlib import Path

target_dir, label, script_path, description, cron, schedule_human = sys.argv[1:7]
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S+00:00")
vista_dir = Path.home() / ".vista"
vista_dir.mkdir(parents=True, exist_ok=True)

# --- automation-library.json ---
library_path = vista_dir / "automation-library.json"
data = json.loads(library_path.read_text(encoding="utf-8")) if library_path.exists() else {"entries": []}
data["entries"] = [e for e in data.get("entries", []) if e.get("label") != label]
data["entries"].append({
    "label": label,
    "plist": f"~/Library/LaunchAgents/{label}.plist",
    "working_dir": target_dir,
    "scripts": [script_path],
    "schedule": schedule_human,
    "cron": cron,
    "status": "active",
    "registered_at": now,
    "description": description,
    "registered_by": "setup-infrastructure.sh",
    "task_ids": [],
    "prd_path": "",
    "manifest_path": "",
})
library_path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"automation-library updated: {label}")

# --- vista-official-plists.json ---
official_path = vista_dir / "vista-official-plists.json"
official = json.loads(official_path.read_text(encoding="utf-8")) if official_path.exists() else {"entries": []}
official["entries"] = [e for e in official.get("entries", []) if e.get("label") != label]
official["entries"].append({
    "label": label,
    "plist": f"~/Library/LaunchAgents/{label}.plist",
    "registered_at": now,
})
official_path.write_text(json.dumps(official, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"vista-official-plists updated: {label}")
PYEOF
}

# --- plist-ledger-sync-checker (every hour at :00) ---
_register \
  "com.vista.plist-ledger-sync-checker" \
  "$TARGET_DIR/scripts/plist-ledger-sync-checker/run_script.sh" \
  "StartCalendarInterval" \
  "<dict>
    <key>Minute</key>
    <integer>0</integer>
  </dict>" \
  "LaunchAgent plistと台帳(automation-library.json)の乖離を毎時検知し、Claude Codeのoneshotで自動修正する" \
  "0 * * * *" \
  "毎時 :00"

# --- Add future infrastructure agents here using _register ---

echo ""
echo "Infrastructure setup complete."
echo "  Logs: /tmp/com.vista.<name>.log"
