"""plist-ledger-sync-checker — main entry point.

Detects drift between ~/Library/LaunchAgents/com.vista.* plist files and
~/.vista/automation-library.json, then fixes issues in Python directly.
"""
from __future__ import annotations

import logging
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

# Issue types that can be fixed automatically
_AUTO_FIXABLE = {"zombie_entry", "ghost_plist", "label_mismatch"}


def run() -> None:
    logger.info("=== %s started ===", SELF_LABEL)

    sys.path.insert(0, str(SCRIPT_DIR))
    from checker import detect
    from fixer import fix

    all_issues = detect(LIBRARY_PATH, LAUNCH_AGENTS_DIR)

    # Exclude self to prevent recursive fix attempts
    issues = [i for i in all_issues if i.label != SELF_LABEL]

    if not issues:
        logger.info("No drift detected.")
        logger.info("=== %s finished ===", SELF_LABEL)
        return

    logger.warning("%d drift issue(s) detected:", len(issues))
    for issue in issues:
        logger.warning("  [%s] %s — %s", issue.type, issue.label, issue.detail)

    fixed, skipped, failed = [], [], []

    for issue in issues:
        if issue.type not in _AUTO_FIXABLE:
            skipped.append(issue)
            logger.info("  SKIP [%s] %s — manual review required", issue.type, issue.label)
            continue

        success, msg = fix(issue, LIBRARY_PATH, LAUNCH_AGENTS_DIR, WORKING_DIR)
        if success:
            fixed.append(issue)
            logger.info("  FIXED [%s] %s — %s", issue.type, issue.label, msg)
        else:
            failed.append(issue)
            logger.error("  FAILED [%s] %s — %s", issue.type, issue.label, msg)

    logger.info(
        "Result: %d fixed / %d skipped / %d failed",
        len(fixed), len(skipped), len(failed),
    )
    if failed:
        logger.error(
            "Unresolved issues require manual intervention: %s",
            ", ".join(f"[{i.type}] {i.label}" for i in failed),
        )

    logger.info("=== %s finished ===", SELF_LABEL)


if __name__ == "__main__":
    run()
