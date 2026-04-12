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

---

## Logging

### Log file paths

LaunchAgent plist must redirect stdout and stderr to `/tmp/`:

```xml
<key>StandardOutPath</key>
<string>/tmp/com.vista.{slug}.log</string>
<key>StandardErrorPath</key>
<string>/tmp/com.vista.{slug}-error.log</string>
```

### Python logging setup

`main.py` must configure logging with these two handlers:

```python
import logging

_stderr_handler = logging.StreamHandler()
_stderr_handler.setLevel(logging.ERROR)   # ERROR and above only → stderr

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/tmp/com.vista.{slug}.log'),  # INFO and above → log file
        _stderr_handler,                                    # ERROR and above → stderr
    ]
)
```

Rules:
- `FileHandler` writes INFO and above to `/tmp/com.vista.{slug}.log`
- `StreamHandler` is restricted to ERROR and above via `setLevel(logging.ERROR)`
  - This prevents INFO logs from polluting `-error.log` (stderr redirect)
  - Only genuine errors appear in the error log, making monitoring reliable
- Do **not** use bare `logging.StreamHandler()` without `setLevel` — it defaults to DEBUG and writes all logs to stderr
