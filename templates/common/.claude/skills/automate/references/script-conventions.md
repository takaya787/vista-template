# Script Conventions — Implementation Phase

All automations implemented via `/impl-prd` or `/automate` MUST follow this structure.

---

## Directory Layout

```
{working_dir}/
└── scripts/
    └── {slug}/
        ├── run_script.sh      ← entry point (ALWAYS this name)
        ├── main.py            ← core logic
        ├── requirements.txt   ← Python dependencies for this automation
        └── *.py               ← additional modules as needed
```

Rules:
- Every automation lives under `scripts/{slug}/` — never a flat file in `scripts/`
- The entry point is **always** `run_script.sh` — the plist calls nothing else
- `main.py` contains the core logic; helper modules are additional `.py` files
- `requirements.txt` is per-automation (not shared with other automations)

---

## run_script.sh Template

```bash
#!/bin/bash
# Entry point for com.vista.{slug}
# Called by LaunchAgent — does not inherit login shell PATH or venv.

set -euo pipefail

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Resolve working_dir from script location (scripts/{slug}/ → working_dir)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKING_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "$WORKING_DIR"

# Activate venv
source tmp/venv/bin/activate

# Execute
exec python "${SCRIPT_DIR}/main.py" "$@"
```

- `set -euo pipefail` — fail fast on errors
- PATH is always set explicitly (LaunchAgent does not inherit shell PATH)
- `WORKING_DIR` is derived from the script's own location — no hardcoded absolute paths
- `exec` replaces the shell process with Python (cleaner process tree)

---

## automation-library.json — scripts field

`scripts[0]` is always the absolute path to `run_script.sh`:

```json
"scripts": [
  "/Users/{user}/private/{user}/{workspace}/scripts/{slug}/run_script.sh"
]
```

Additional scripts (helpers, secondary tasks) go in `scripts[1+]`.

---

## plist ProgramArguments

Because `run_script.sh` handles venv activation and `cd` internally,
the plist only needs to call the script:

```xml
<key>ProgramArguments</key>
<array>
  <string>/bin/bash</string>
  <string>/Users/{user}/private/{user}/{workspace}/scripts/{slug}/run_script.sh</string>
</array>
```

Do **not** add `source venv` or `cd` in the plist — `run_script.sh` owns that.

---

## venv Setup

venv is shared across automations within the same workspace:

```bash
# Create once per workspace (Phase 0)
python -m venv tmp/venv
source tmp/venv/bin/activate
pip install -r scripts/{slug}/requirements.txt
```

Each automation's `requirements.txt` is installed into the shared `tmp/venv`.
If workspaces are isolated projects, each has its own `tmp/venv`.
