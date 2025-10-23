#!/usr/bin/env python3
"""Scan Markdown files for broken relative links.

Warnings are printed but the script never exits with a non-zero status to keep
it safe for early adoption in CI.
"""
from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Tuple

REPO_ROOT = Path(__file__).resolve().parents[1]
LINK_PATTERN = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
EXCLUDE_DIRS = {".git", "__pycache__", "node_modules", "site", ".venv"}


@dataclass
class LinkIssue:
    file: Path
    target: str
    line_number: int
    reason: str


def find_markdown_files(paths: Iterable[Path]) -> List[Path]:
    files: List[Path] = []
    for path in paths:
        if path.is_file() and path.suffix.lower() == ".md":
            files.append(path)
        elif path.is_dir():
            if path.name in EXCLUDE_DIRS:
                continue
            for child in path.iterdir():
                files.extend(find_markdown_files([child]))
    return files


def validate_link(markdown_file: Path, target: str) -> Tuple[bool, str]:
    if target.startswith("http://") or target.startswith("https://"):
        return True, "external"
    if target.startswith("mailto:"):
        return True, "external"
    if target.startswith("#"):
        return True, "anchor"
    anchor = None
    if "#" in target:
        target, anchor = target.split("#", 1)
    resolved = (markdown_file.parent / target).resolve()
    if not resolved.exists():
        return False, "missing file"
    if anchor:
        if not anchor:
            return True, ""
    return True, ""


def scan_file(path: Path) -> List[LinkIssue]:
    issues: List[LinkIssue] = []
    text = path.read_text(encoding="utf-8", errors="ignore")
    for line_number, line in enumerate(text.splitlines(), start=1):
        for match in LINK_PATTERN.finditer(line):
            target = match.group(1)
            valid, reason = validate_link(path, target)
            if not valid:
                issues.append(LinkIssue(file=path, target=target, line_number=line_number, reason=reason))
    return issues


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Lint Markdown links")
    parser.add_argument("paths", nargs="*", type=Path, default=[REPO_ROOT])
    args = parser.parse_args(list(argv) if argv is not None else None)

    files = find_markdown_files(args.paths)
    issues: List[LinkIssue] = []
    for file in files:
        issues.extend(scan_file(file))

    if issues:
        print("Link warnings:")
        for issue in issues:
            rel = issue.file.relative_to(REPO_ROOT)
            print(f"  {rel}:{issue.line_number} -> {issue.target} ({issue.reason})")
    else:
        print("No link issues detected.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
