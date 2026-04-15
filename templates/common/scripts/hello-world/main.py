"""hello-world — sample automation entry point.

Demonstrates the standard script structure for Vista automations.
Replace this module with your scenario-specific logic.
"""
import logging
import sys
from datetime import date
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = SCRIPT_DIR / "output"
LOG_FILE = Path("/tmp/com.vista.hello-world.log")

# ---------------------------------------------------------------------------
# Logging setup — follow script-conventions.md exactly:
#   FileHandler  → INFO and above  → /tmp/com.vista.{slug}.log
#   StreamHandler → ERROR and above → stderr (prevents INFO from polluting
#                                     the LaunchAgent error log)
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
    logger.info("=== hello-world started ===")
    today = date.today().isoformat()

    # ------------------------------------------------------------------
    # Phase 1: Fetch / collect data
    # Replace with your actual data-fetching logic.
    # ------------------------------------------------------------------
    logger.info("Phase 1: fetching data...")
    data = _fetch()

    if not data:
        logger.error("No data returned. Aborting.")
        sys.exit(1)

    logger.info("Fetched %d items.", len(data))

    # ------------------------------------------------------------------
    # Phase 2: Process / transform
    # Replace with your actual processing logic.
    # ------------------------------------------------------------------
    logger.info("Phase 2: processing data...")
    result = _process(data)

    # ------------------------------------------------------------------
    # Phase 3: Write output
    # ------------------------------------------------------------------
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_file = OUTPUT_DIR / f"{today}.txt"
    output_file.write_text("\n".join(result), encoding="utf-8")
    logger.info("Output written: %s", output_file)

    logger.info("=== hello-world finished ===")


# ---------------------------------------------------------------------------
# Internal helpers — replace with real implementations
# ---------------------------------------------------------------------------

def _fetch() -> list[str]:
    """Fetch raw items from the data source."""
    # TODO: implement actual fetch logic
    return ["item-1", "item-2", "item-3"]


def _process(items: list[str]) -> list[str]:
    """Transform raw items into output lines."""
    # TODO: implement actual processing logic
    return [f"processed: {item}" for item in items]


if __name__ == "__main__":
    run()
