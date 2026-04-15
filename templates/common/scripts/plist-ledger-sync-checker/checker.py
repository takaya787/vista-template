"""Drift detection between ~/Library/LaunchAgents/com.vista.* and automation-library.json."""
from __future__ import annotations

import json
import plistlib
from dataclasses import dataclass, field
from pathlib import Path

OFFICIAL_PLISTS_PATH = Path.home() / ".vista" / "vista-official-plists.json"


def _load_official_labels(official_path: Path) -> set[str]:
    """Return the set of labels managed by setup-infrastructure.sh."""
    if not official_path.exists():
        return set()
    data = json.loads(official_path.read_text(encoding="utf-8"))
    return {e["label"] for e in data.get("entries", []) if "label" in e}


@dataclass
class Issue:
    type: str   # ghost_plist | zombie_entry | label_mismatch | missing_run_script | parse_error
    label: str
    detail: str
    is_official: bool = field(default=False)   # True = managed by setup-infrastructure.sh


def detect(library_path: Path, launch_agents_dir: Path) -> list[Issue]:
    """Compare plist files vs ledger entries and return all drift issues."""
    issues: list[Issue] = []
    official_labels = _load_official_labels(OFFICIAL_PLISTS_PATH)

    # --- Load ledger ---
    if not library_path.exists():
        return []  # No ledger yet — nothing to validate against

    data = json.loads(library_path.read_text(encoding="utf-8"))
    ledger: dict[str, dict] = {
        e["label"]: e for e in data.get("entries", [])
    }

    # --- Load com.vista.* plist files ---
    plists: dict[str, dict] = {}
    for plist_file in sorted(launch_agents_dir.glob("com.vista.*.plist")):
        try:
            with plist_file.open("rb") as f:
                pdata = plistlib.load(f)
            plists[plist_file.stem] = {"file": plist_file, "data": pdata}
        except Exception as exc:
            issues.append(Issue(
                type="parse_error",
                label=plist_file.stem,
                detail=f"Cannot parse {plist_file.name}: {exc}",
                is_official=plist_file.stem in official_labels,
            ))

    # --- Ghost: plist file exists but no ledger entry ---
    for stem, info in plists.items():
        label = info["data"].get("Label", stem)
        if label not in ledger:
            issues.append(Issue(
                type="ghost_plist",
                label=label,
                detail=(
                    f"{info['file'].name} exists in LaunchAgents but has no ledger entry. "
                    f"ProgramArguments: {info['data'].get('ProgramArguments', [])}"
                ),
                is_official=label in official_labels,
            ))

    # --- Zombie: ledger entry exists but plist file is missing ---
    for label in ledger:
        if label not in plists:
            raw_plist = ledger[label].get("plist", "")
            plist_name = Path(raw_plist.replace("~", str(Path.home()))).name
            issues.append(Issue(
                type="zombie_entry",
                label=label,
                detail=f"Ledger has '{label}' but {plist_name} not found in LaunchAgents",
                is_official=label in official_labels,
            ))

    # --- Label mismatch: plist Label key != filename stem ---
    for stem, info in plists.items():
        plist_label = info["data"].get("Label", "")
        if plist_label and plist_label != stem:
            issues.append(Issue(
                type="label_mismatch",
                label=stem,
                detail=(
                    f"{info['file'].name}: Label in plist is '{plist_label}' "
                    f"but filename stem is '{stem}'"
                ),
                is_official=stem in official_labels,
            ))

    # --- Convention: ProgramArguments must end with run_script.sh ---
    for stem, info in plists.items():
        args = info["data"].get("ProgramArguments", [])
        if args and not str(args[-1]).endswith("run_script.sh"):
            label = info["data"].get("Label", stem)
            issues.append(Issue(
                type="missing_run_script",
                label=label,
                detail=(
                    f"{label}: ProgramArguments last element is '{args[-1]}', "
                    f"expected run_script.sh (script-conventions.md violation)"
                ),
                is_official=label in official_labels,
            ))

    return issues
