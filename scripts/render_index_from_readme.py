#!/usr/bin/env python3
"""Render docs/index.md from the root README."""
from __future__ import annotations

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
README_PATH = REPO_ROOT / "README.md"
DOCS_INDEX = REPO_ROOT / "docs" / "index.md"
HEADER = "<!-- DO NOT EDIT: generated from README.md via render_index_from_readme.py -->\n"


def main() -> int:
    if not README_PATH.exists():
        raise SystemExit("README.md not found")

    readme_content = README_PATH.read_text(encoding="utf-8")
    transformed = readme_content
    transformed = transformed.replace("](docs/)", "](./)")
    transformed = re.sub(r"\((?:\./)?docs/", "(", transformed)
    transformed = re.sub(r"\((?:\./)?\.github/", "(../.github/", transformed)
    output = HEADER + transformed
    DOCS_INDEX.parent.mkdir(parents=True, exist_ok=True)
    DOCS_INDEX.write_text(output, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
