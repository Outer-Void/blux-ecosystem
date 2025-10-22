# INSTALL

> *Bring the constellation online with one breath, any platform.*

## Installation Matrix
| Platform | Prerequisites | Install Steps | Verification |
| --- | --- | --- | --- |
| Linux (Ubuntu/Fedora) | Python 3.11+, Docker, Make, Git | `./scripts/bootstrap.sh` then `python -m venv .venv && source .venv/bin/activate` | `./scripts/health-check.sh` and `bluxq --version` |
| macOS (Intel/Apple Silicon) | Homebrew, Python 3.11+, Docker Desktop | `brew bundle --file=tools/Brewfile` (if present) then `./scripts/bootstrap.sh` | `./scripts/health-check.sh` and `bluxq doctor` |
| Windows (WSL2) | Ubuntu distro, Docker Desktop integration | Clone repo inside WSL2, run `./scripts/bootstrap.sh`, install PowerShell module via `pwsh -File tools/setup.ps1` (if available) | `./scripts/health-check.sh` inside WSL and `pwsh -Command "bluxq --help"` |
| Air-gapped | Offline package mirror, container runtime | Mirror artifacts described in `config/artifacts.yaml`, run `./scripts/bootstrap.sh --offline` | `./scripts/health-check.sh --offline` |

## Quick Start (Unified)
```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/Outer-Void/blux-ecosystem.git
cd blux-ecosystem

# Optional: set up Python environment
python -m venv .venv
source .venv/bin/activate  # Windows PowerShell: .venv\\Scripts\\Activate.ps1

# Bootstrap dependencies
./scripts/bootstrap.sh

# Synchronize docs and file tree
python scripts/scan_subrepos.py
python scripts/update_readme_filetree.py
python scripts/render_index_from_readme.py

# Build docs site
mkdocs build
```

## PowerShell Quick Start
```powershell
# Clone
git clone --recurse-submodules https://github.com/Outer-Void/blux-ecosystem.git
Set-Location blux-ecosystem

# Optional venv
python -m venv .venv
. .venv/Scripts/Activate.ps1

# Bootstrap
bash ./scripts/bootstrap.sh

# Validate
yarn --version  # if Commander UI is enabled
python scripts/scan_subrepos.py
```

## CLI Binary
`bluxq` binaries are distributed via the BLUX Quantum module. For local development, install with:
```bash
pip install -e ./blux-quantum  # if sub-repo available
```
PowerShell equivalent:
```powershell
pip install -e ./blux-quantum
```

## Container Compose
For full-ecosystem simulations:
```bash
docker compose -f config/compose/full.yml up -d
bluxq status --format table
```

## Environment Variables
Populate `.env` or export runtime variables described in [CONFIGURATION](CONFIGURATION.md).

## Next Steps
- Review the [OPERATIONS](OPERATIONS.md) runbook.
- Explore module guides in `docs/modules/*` with `mkdocs serve` for live previews.
