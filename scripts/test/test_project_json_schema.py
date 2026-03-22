#!/usr/bin/env python3
"""
Test that the project.json skeleton in copy-common.sh has the same keys as project.example.json.

Usage:
    python3 scripts/test/test_project_json_schema.py
"""

import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent
COPY_COMMON = REPO_ROOT / "scripts" / "copy-common.sh"
PROJECT_EXAMPLE = REPO_ROOT / "templates" / "common" / ".vista" / "profile" / "project.example.json"


def extract_skeleton_json(sh_path: Path) -> dict:
    text = sh_path.read_text()
    # Extract the heredoc for project.json (between the cat > ... << EOF and closing EOF)
    match = re.search(
        r'cat > "\$TARGET_DIR/\.vista/profile/project\.json" << EOF\n(.*?)\nEOF',
        text,
        re.DOTALL,
    )
    if not match:
        raise ValueError("Could not find project.json heredoc in copy-common.sh")

    heredoc = match.group(1)
    # Replace shell variables with placeholder strings so JSON parses cleanly
    heredoc = re.sub(r'\$\{[^}]+\}', '__SHELL_VAR__', heredoc)
    return json.loads(heredoc)


def collect_keys(obj, prefix=""):
    """Recursively collect all dotted key paths from a dict."""
    keys = set()
    if isinstance(obj, dict):
        for k, v in obj.items():
            path = f"{prefix}.{k}" if prefix else k
            keys.add(path)
            keys |= collect_keys(v, path)
    return keys


def main():
    example = json.loads(PROJECT_EXAMPLE.read_text())
    skeleton = extract_skeleton_json(COPY_COMMON)

    example_keys = collect_keys(example)
    skeleton_keys = collect_keys(skeleton)

    missing = sorted(example_keys - skeleton_keys)
    extra = sorted(skeleton_keys - example_keys)

    if not missing and not extra:
        print("PASS: skeleton keys match project.example.json")
        return

    print("FAIL: key mismatch between copy-common.sh skeleton and project.example.json\n")
    if missing:
        print("MISSING in skeleton (present in example):")
        for k in missing:
            print(f"  - {k}")
    if extra:
        print("EXTRA in skeleton (not in example):")
        for k in extra:
            print(f"  + {k}")
    sys.exit(1)


if __name__ == "__main__":
    main()
