#!/usr/bin/env python3
"""Synchronize module documentation stubs from sub-repositories.

The script is intentionally idempotent: it creates missing files but never
overwrites hand-crafted documentation. When a module repository is available
as a sibling checkout or git submodule, the script links to the upstream
sources so writers know where the canonical material lives.
"""
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional

REPO_ROOT = Path(__file__).resolve().parents[1]
DOCS_ROOT = REPO_ROOT / "docs"
MODULE_DOCS_ROOT = DOCS_ROOT / "modules"
ARCHITECTURE_DOC = DOCS_ROOT / "ARCHITECTURE.md"

@dataclass
class ModuleSpec:
    key: str
    display_name: str
    tagline: str
    repo_urls: List[str]
    doc_filenames: Dict[str, str]

    @property
    def doc_directory(self) -> Path:
        return MODULE_DOCS_ROOT / self.key

MODULE_SPECS: List[ModuleSpec] = [
    ModuleSpec(
        key="blux-lite",
        display_name="BLUX Lite",
        tagline="Orchestrates the pulse of autonomous workflows with doctrine as compass.",
        repo_urls=["https://github.com/Outer-Void/blux-lite"],
        doc_filenames={
            "README": "README.md",
            "ARCHITECTURE": "ARCHITECTURE.md",
            "INTEGRATION_GUIDE": "INTEGRATION_GUIDE.md",
            "OPERATIONS": "OPERATIONS.md",
            "SECURITY": "SECURITY.md",
            "CONFIGURATION": "CONFIGURATION.md",
            "API": "API.md",
        },
    ),
    ModuleSpec(
        key="blux-ca",
        display_name="BLUX cA",
        tagline="Conscious advisory whispering doctrine-aligned insight.",
        repo_urls=["https://github.com/Outer-Void/blux-ca"],
        doc_filenames={
            "README": "README.md",
            "ARCHITECTURE": "ARCHITECTURE.md",
            "INTEGRATION_GUIDE": "INTEGRATION_GUIDE.md",
            "OPERATIONS": "OPERATIONS.md",
            "SECURITY": "SECURITY.md",
            "CONFIGURATION": "CONFIGURATION.md",
            "API": "API.md",
        },
    ),
    ModuleSpec(
        key="blux-guard",
        display_name="BLUX Guard",
        tagline="The sentinel cockpit where trust is enforced.",
        repo_urls=["https://github.com/Outer-Void/blux-guard"],
        doc_filenames={
            "README": "README.md",
            "ARCHITECTURE": "ARCHITECTURE.md",
            "INTEGRATION_GUIDE": "INTEGRATION_GUIDE.md",
            "OPERATIONS": "OPERATIONS.md",
            "SECURITY": "SECURITY.md",
            "CONFIGURATION": "CONFIGURATION.md",
            "API": "API.md",
        },
    ),
    ModuleSpec(
        key="blux-quantum",
        display_name="BLUX Quantum (CLI)",
        tagline="Single CLI to command the constellation.",
        repo_urls=["https://github.com/Outer-Void/blux-quantum"],
        doc_filenames={
            "README": "README.md",
            "ARCHITECTURE": "ARCHITECTURE.md",
            "INTEGRATION_GUIDE": "INTEGRATION_GUIDE.md",
            "OPERATIONS": "OPERATIONS.md",
            "SECURITY": "SECURITY.md",
            "CONFIGURATION": "CONFIGURATION.md",
            "API": "API.md",
        },
    ),
    ModuleSpec(
        key="blux-doctrine",
        display_name="BLUX Doctrine",
        tagline="Values codified, guiding every decision.",
        repo_urls=["https://github.com/Outer-Void/blux-doctrine"],
        doc_filenames={
            "README": "README.md",
            "ARCHITECTURE": "ARCHITECTURE.md",
            "INTEGRATION_GUIDE": "INTEGRATION_GUIDE.md",
            "OPERATIONS": "OPERATIONS.md",
            "SECURITY": "SECURITY.md",
            "CONFIGURATION": "CONFIGURATION.md",
            "API": "API.md",
        },
    ),
    ModuleSpec(
        key="blux-commander",
        display_name="BLUX Commander",
        tagline="The command bridge where operators see and steer.",
        repo_urls=["https://github.com/Outer-Void/blux-commander"],
        doc_filenames={
            "README": "README.md",
            "ARCHITECTURE": "ARCHITECTURE.md",
            "INTEGRATION_GUIDE": "INTEGRATION_GUIDE.md",
            "OPERATIONS": "OPERATIONS.md",
            "SECURITY": "SECURITY.md",
            "CONFIGURATION": "CONFIGURATION.md",
            "API": "API.md",
        },
    ),
    ModuleSpec(
        key="blux-reg",
        display_name="BLUX Reg",
        tagline="Identity forge and capability ledger.",
        repo_urls=["https://github.com/Outer-Void/blux-reg"],
        doc_filenames={
            "README": "README.md",
            "ARCHITECTURE": "ARCHITECTURE.md",
            "INTEGRATION_GUIDE": "INTEGRATION_GUIDE.md",
            "OPERATIONS": "OPERATIONS.md",
            "SECURITY": "SECURITY.md",
            "CONFIGURATION": "CONFIGURATION.md",
            "API": "API.md",
        },
    ),
]


def discover_subrepo_path(module: ModuleSpec) -> Optional[Path]:
    """Return the path to the module repository if available."""
    candidates = [
        REPO_ROOT / module.key,
        REPO_ROOT / module.key.replace("-", "_"),
        REPO_ROOT / "modules" / module.key,
        REPO_ROOT / "modules" / module.key.replace("-", "_"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def discover_source(module: ModuleSpec, doc_name: str) -> Optional[Path]:
    """Attempt to locate a matching file in the sub-repository."""
    subrepo = discover_subrepo_path(module)
    if subrepo is None:
        return None
    candidates = [
        subrepo / module.doc_filenames[doc_name],
        subrepo / module.doc_filenames[doc_name].lower(),
        subrepo / "docs" / module.doc_filenames[doc_name],
        subrepo / "docs" / module.doc_filenames[doc_name].lower(),
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def ensure_module_docs(module: ModuleSpec) -> List[str]:
    """Create placeholder documentation files when missing."""
    created: List[str] = []
    module.doc_directory.mkdir(parents=True, exist_ok=True)
    for doc_name, filename in module.doc_filenames.items():
        destination = module.doc_directory / filename
        if destination.exists():
            continue
        source_path = discover_source(module, doc_name)
        if source_path:
            relative = Path("..") / Path("..") / source_path.relative_to(REPO_ROOT)
            source_link = relative.as_posix()
        else:
            source_link = module.repo_urls[0]
        template = build_template(module, doc_name, source_link)
        destination.write_text(template, encoding="utf-8")
        created.append(str(destination.relative_to(REPO_ROOT)))
    return created


def build_template(module: ModuleSpec, doc_name: str, source_link: str) -> str:
    """Generate a minimal documentation template."""
    title_fragment = doc_name.replace("_", " ").title()
    if doc_name == "API":
        title_fragment = "API / COMMANDS"
    title = f"{module.display_name} {title_fragment}".strip()
    lines = [
        f"# {title}",
        "",
        f"> *{module.tagline}*",
        "",
        "## Overview",
        "Describe the purpose and placement of this module document.",
        "",
        "## Quick Start",
        "```bash",
        f"bluxq {module.key.split('-')[-1]} --help",
        "```",
        "",
        f"Source: [{source_link}]({source_link})",
        "",
    ]
    return "\n".join(lines)


def update_architecture_index() -> bool:
    """Ensure the module table inside docs/ARCHITECTURE.md is current."""
    if not ARCHITECTURE_DOC.exists():
        return False
    content = ARCHITECTURE_DOC.read_text(encoding="utf-8")
    begin = "<!-- MODULE-DOCS:BEGIN -->"
    end = "<!-- MODULE-DOCS:END -->"
    if begin not in content or end not in content:
        return False

    table_lines = [
        "| Module | README | Architecture | Integration | Operations | Security | Configuration | API/Commands |",
        "| --- | --- | --- | --- | --- | --- | --- | --- |",
    ]
    for module in MODULE_SPECS:
        base = f"modules/{module.key}"
        row = (
            f"| {module.display_name} | "
            f"[Link]({base}/README.md) | "
            f"[Link]({base}/ARCHITECTURE.md) | "
            f"[Link]({base}/INTEGRATION_GUIDE.md) | "
            f"[Link]({base}/OPERATIONS.md) | "
            f"[Link]({base}/SECURITY.md) | "
            f"[Link]({base}/CONFIGURATION.md) | "
            f"[Link]({base}/API.md) |"
        )
        table_lines.append(row)
    replacement = "\n".join([begin, *table_lines, end])
    if begin in content and end in content:
        new_content = content.split(begin)[0] + replacement + content.split(end)[1]
        if new_content != content:
            ARCHITECTURE_DOC.write_text(new_content, encoding="utf-8")
            return True
    return False


def main(argv: Optional[Iterable[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Ensure module documentation exists")
    parser.add_argument("--json", action="store_true", help="Emit JSON summary")
    args = parser.parse_args(list(argv) if argv is not None else None)

    summary: Dict[str, List[str]] = {"created": []}
    for module in MODULE_SPECS:
        created = ensure_module_docs(module)
        if created:
            summary["created"].extend(created)

    changed_architecture = update_architecture_index()
    if changed_architecture:
        summary.setdefault("updated", []).append(str(ARCHITECTURE_DOC.relative_to(REPO_ROOT)))

    if args.json:
        print(json.dumps(summary, indent=2))
    else:
        if summary["created"]:
            print("Created:")
            for path in summary["created"]:
                print(f"  - {path}")
        if "updated" in summary:
            print("Updated:")
            for path in summary["updated"]:
                print(f"  - {path}")
        if not summary["created"] and "updated" not in summary:
            print("No changes required.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
