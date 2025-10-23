#!/usr/bin/env python3
"""Generate a concise repository file tree.

The output is designed to live inside README.md within a fenced code block.
"""
from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable, List

REPO_ROOT = Path(__file__).resolve().parents[1]
EXCLUDE = {".git", "__pycache__", "node_modules", "site", ".venv"}


def should_skip(path: Path) -> bool:
    parts = set(path.parts)
    return bool(parts & EXCLUDE)


def build_tree(root: Path, prefix: str = "") -> List[str]:
    entries = [p for p in sorted(root.iterdir(), key=lambda p: p.name.lower()) if not should_skip(p.relative_to(REPO_ROOT))]
    lines: List[str] = []
    for index, entry in enumerate(entries):
        connector = "└──" if index == len(entries) - 1 else "├──"
        lines.append(f"{prefix}{connector} {entry.name}")
        if entry.is_dir():
            extension = "    " if connector == "└──" else "│   "
            lines.extend(build_tree(entry, prefix + extension))
    return lines


def generate_tree() -> str:
    lines = [REPO_ROOT.name + "/"]
    lines.extend(build_tree(REPO_ROOT))
    return "\n".join(lines)


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Generate repository file tree")
    parser.add_argument("--output", "-o", type=Path, help="Optional path to write output")
    args = parser.parse_args(list(argv) if argv is not None else None)

    tree = generate_tree()
    if args.output:
        args.output.write_text(tree, encoding="utf-8")
    else:
        print(tree)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
