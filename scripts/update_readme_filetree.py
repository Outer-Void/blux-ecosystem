#!/usr/bin/env python3
"""Insert the generated file tree into README.md."""
from __future__ import annotations

import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
README_PATH = REPO_ROOT / "README.md"
MARKER_BEGIN = "<!-- FILETREE:BEGIN -->"
MARKER_END = "<!-- FILETREE:END -->"
GENERATED_NOTE = "<!-- generated; do not edit manually -->"


def generate_tree_text() -> str:
    result = subprocess.run(
        ["python", str(REPO_ROOT / "scripts" / "gen_filetree.py")],
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def build_block(tree_text: str) -> str:
    return (
        f"{MARKER_BEGIN}\n"
        f"{GENERATED_NOTE}\n"
        "<details><summary><strong>Repository File Tree</strong> (click to expand)</summary>\n\n"
        "```text\n"
        f"{tree_text}\n"
        "```\n\n"
        "</details>\n"
        f"{MARKER_END}"
    )


def main() -> int:
    tree_text = generate_tree_text()
    block = build_block(tree_text)

    if README_PATH.exists():
        content = README_PATH.read_text(encoding="utf-8")
    else:
        content = ""

    if MARKER_BEGIN in content and MARKER_END in content:
        before, _sep, rest = content.partition(MARKER_BEGIN)
        _, _sep2, after = rest.partition(MARKER_END)
        new_content = before + block + after
    else:
        new_content = content.rstrip() + "\n\n" + block + "\n"

    if new_content != content:
        README_PATH.write_text(new_content, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
