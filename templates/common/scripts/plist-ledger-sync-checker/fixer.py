"""Fix strategies for each drift issue type.

All fixes are implemented in pure Python — no Claude invocation.
"""
from __future__ import annotations

import json
import plistlib
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from checker import Issue

# setup-infrastructure.sh is installed to ~/.vista/vista-template/ by install.sh
SETUP_SH = Path.home() / ".vista" / "vista-template" / "scripts" / "setup-infrastructure.sh"


def fix(
    issue: Issue,
    library_path: Path,
    launch_agents_dir: Path,
    working_dir: Path,
) -> tuple[bool, str]:
    """Attempt to fix a single issue. Returns (success, message)."""
    if issue.type == "zombie_entry":
        return _fix_zombie(issue, library_path, working_dir)
    if issue.type == "ghost_plist":
        return _fix_ghost(issue, library_path, launch_agents_dir)
    if issue.type == "label_mismatch":
        return _fix_label_mismatch(issue, library_path, launch_agents_dir)
    # missing_run_script / parse_error — requires manual review
    return False, f"No auto-fix for '{issue.type}' — manual review required"


# ---------------------------------------------------------------------------
# Per-type fix implementations
# ---------------------------------------------------------------------------

def _fix_zombie(issue: Issue, library_path: Path, working_dir: Path) -> tuple[bool, str]:
    """Zombie entry: ledger has label but plist file is missing."""
    if issue.is_official and SETUP_SH.exists():
        # Official infra: re-run setup-infrastructure.sh to recreate plist + update ledger
        result = subprocess.run(
            ["bash", str(SETUP_SH), str(working_dir)],
            capture_output=True,
            text=True,
            timeout=120,
        )
        if result.returncode == 0:
            return True, "Restored via setup-infrastructure.sh"
        # Fall through to ledger cleanup if setup script fails
    # User automation (or official fallback): just remove the stale ledger entry
    return _remove_from_ledger(issue.label, library_path)


def _fix_ghost(
    issue: Issue,
    library_path: Path,
    launch_agents_dir: Path,
) -> tuple[bool, str]:
    """Ghost plist: plist file exists but has no ledger entry — reconstruct from plist."""
    plist_file = launch_agents_dir / f"{issue.label}.plist"
    if not plist_file.exists():
        return False, f"Plist file not found: {plist_file.name}"

    try:
        with plist_file.open("rb") as f:
            pdata = plistlib.load(f)
    except Exception as exc:
        return False, f"Cannot parse plist: {exc}"

    label = pdata.get("Label", issue.label)
    args = pdata.get("ProgramArguments", [])
    script_path = args[-1] if args else ""
    working_dir = pdata.get("WorkingDirectory", "")
    schedule_human, cron = _parse_schedule(pdata)

    data = json.loads(library_path.read_text(encoding="utf-8")) if library_path.exists() else {"entries": []}
    data["entries"] = [e for e in data.get("entries", []) if e.get("label") != label]
    data["entries"].append({
        "label": label,
        "plist": f"~/Library/LaunchAgents/{label}.plist",
        "working_dir": working_dir,
        "scripts": [script_path] if script_path else [],
        "schedule": schedule_human,
        "cron": cron,
        "status": "active",
        "registered_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S+00:00"),
        "description": "",
        "registered_by": "plist-ledger-sync-checker (auto-recovered)",
        "task_ids": [],
        "prd_path": "",
        "manifest_path": "",
    })
    library_path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return True, f"Reconstructed ledger entry for '{label}' (description field is empty — update manually)"


def _fix_label_mismatch(
    issue: Issue,
    library_path: Path,
    launch_agents_dir: Path,
) -> tuple[bool, str]:
    """Label mismatch: update ledger label to match the plist Label key."""
    plist_file = launch_agents_dir / f"{issue.label}.plist"
    if not plist_file.exists():
        return False, f"Plist file not found: {plist_file.name}"

    try:
        with plist_file.open("rb") as f:
            pdata = plistlib.load(f)
    except Exception as exc:
        return False, f"Cannot parse plist: {exc}"

    correct_label = pdata.get("Label", "")
    if not correct_label:
        return False, "Label key missing in plist"

    if not library_path.exists():
        return False, "Ledger not found"

    data = json.loads(library_path.read_text(encoding="utf-8"))
    updated = False
    for entry in data.get("entries", []):
        if entry.get("label") == issue.label:
            entry["label"] = correct_label
            entry["plist"] = f"~/Library/LaunchAgents/{correct_label}.plist"
            updated = True
            break

    if not updated:
        return False, f"Entry '{issue.label}' not found in ledger"

    library_path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return True, f"Updated label '{issue.label}' → '{correct_label}'"


# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------

def _remove_from_ledger(label: str, library_path: Path) -> tuple[bool, str]:
    if not library_path.exists():
        return False, "Ledger not found"
    data = json.loads(library_path.read_text(encoding="utf-8"))
    before = len(data.get("entries", []))
    data["entries"] = [e for e in data["entries"] if e.get("label") != label]
    if len(data["entries"]) == before:
        return False, f"Entry '{label}' not found in ledger"
    library_path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return True, f"Removed stale entry '{label}' from ledger"


def _parse_schedule(pdata: dict) -> tuple[str, str]:
    """Extract human-readable schedule and cron expression from plist data."""
    if "StartInterval" in pdata:
        secs = int(pdata["StartInterval"])
        if secs == 3600:
            return "毎時", "0 * * * *"
        if secs == 86400:
            return "毎日", "0 0 * * *"
        mins = secs // 60
        return f"毎{secs}秒", f"*/{mins} * * * *" if mins > 0 else "* * * * *"

    if "StartCalendarInterval" in pdata:
        cal = pdata["StartCalendarInterval"]
        hour = cal.get("Hour", "*")
        minute = cal.get("Minute", 0)
        weekday = cal.get("Weekday", "*")
        day = cal.get("Day", "*")
        cron = f"{minute} {hour} {day} * {weekday}"

        _days = ["日", "月", "火", "水", "木", "金", "土"]
        if weekday != "*":
            label = f"毎週{_days[int(weekday)]}"
            human = f"{label} {hour:02d}:{minute:02d}" if isinstance(hour, int) else label
        elif day != "*":
            human = f"毎月{day}日 {hour:02d}:{minute:02d}" if isinstance(hour, int) else f"毎月{day}日"
        elif isinstance(hour, int):
            human = f"毎日 {hour:02d}:{minute:02d}"
        else:
            human = f"毎時 :{minute:02d}"
        return human, cron

    return "不明", "* * * * *"
