"""plist-ledger-sync-checker — main entry point.

Detects drift between ~/Library/LaunchAgents/com.vista.* plist files and
~/.vista/automation-library.json, then invokes Claude Code oneshot to fix any issues.
"""
from __future__ import annotations

import logging
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
WORKING_DIR = SCRIPT_DIR.parent.parent            # scripts/plist-ledger-sync-checker/../../
LIBRARY_PATH = Path.home() / ".vista" / "automation-library.json"
LAUNCH_AGENTS_DIR = Path.home() / "Library" / "LaunchAgents"
SELF_LABEL = "com.vista.plist-ledger-sync-checker"
LOG_FILE = Path(f"/tmp/{SELF_LABEL}.log")

# ---------------------------------------------------------------------------
# Logging — FileHandler: INFO and above / StreamHandler: ERROR and above only
# ---------------------------------------------------------------------------
_stderr_handler = logging.StreamHandler()
_stderr_handler.setLevel(logging.ERROR)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE, encoding="utf-8"),
        _stderr_handler,
    ],
)
logger = logging.getLogger(__name__)


def run() -> None:
    logger.info("=== %s started ===", SELF_LABEL)

    sys.path.insert(0, str(SCRIPT_DIR))
    from checker import detect

    all_issues = detect(LIBRARY_PATH, LAUNCH_AGENTS_DIR)

    # Exclude self to prevent recursive fix attempts
    issues = [i for i in all_issues if i.label != SELF_LABEL]

    if not issues:
        logger.info("No drift detected. All plist files and ledger entries are in sync.")
        logger.info("=== %s finished ===", SELF_LABEL)
        return

    logger.warning("%d drift issue(s) detected:", len(issues))
    for issue in issues:
        logger.warning("  [%s] %s — %s", issue.type, issue.label, issue.detail)

    _fix_with_claude(issues)
    logger.info("=== %s finished ===", SELF_LABEL)


def _fix_with_claude(issues) -> None:
    """Invoke Claude Code in oneshot mode to fix the detected drift issues."""
    official = [i for i in issues if i.is_official]
    user     = [i for i in issues if not i.is_official]

    def _fmt(lst) -> str:
        return "\n".join(f"  - [{i.type}] {i.label}: {i.detail}" for i in lst) or "  (none)"

    prompt = f"""\
The plist-ledger-sync-checker detected the following drift between \
~/Library/LaunchAgents/com.vista.*.plist files and ~/.vista/automation-library.json.

## Official infrastructure issues (managed by setup-infrastructure.sh)
{_fmt(official)}

## User automation issues (managed by launch-agent-registrar)
{_fmt(user)}

### Fix instructions
- ghost_plist (official): re-run setup-infrastructure.sh to restore the missing registration; \
do NOT add manually to automation-library.json
- ghost_plist (user): read the plist file, then add the missing entry to \
~/.vista/automation-library.json with all required fields
- zombie_entry: ledger entry exists but plist file is missing → remove the stale entry \
from ~/.vista/automation-library.json
- label_mismatch: plist Label key does not match filename stem → update the ledger entry \
to use the correct label
- missing_run_script: log only, do not auto-fix (requires manual review)

Refer to .claude/agents/launch-agent-registrar.md for ledger field definitions.
Working directory: {WORKING_DIR}
"""

    logger.info("Invoking Claude Code oneshot to fix %d issue(s)...", len(issues))

    result = subprocess.run(
        ["claude", "--print", prompt],
        capture_output=True,
        text=True,
        cwd=str(WORKING_DIR),
    )

    if result.returncode == 0:
        logger.info("Claude fix completed:\n%s", result.stdout.strip())
    else:
        logger.error(
            "Claude fix failed (exit %d):\nstdout: %s\nstderr: %s",
            result.returncode,
            result.stdout.strip(),
            result.stderr.strip(),
        )


if __name__ == "__main__":
    run()
