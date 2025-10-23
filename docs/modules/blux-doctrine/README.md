# BLUX DOCTRINE

> *Values codified, guiding every decision.*

## Overview
BLUX Doctrine encodes ethical principles, governance rules, and policy contracts consumed by every module. It provides versioned manifest files and approval workflows.

## Quick Start
```bash
bluxq doctrine status
bluxq doctrine pulse
bluxq doctrine approve --proposal change-123
```

## Architecture
- **Manifest Store** — Versioned doctrine files signed by Reg.
- **Approval Workflow** — Multi-signer process managed via `bluxq`.
- **Policy API** — Serves doctrine context to Guard, Lite, and cA.

## Integration
- Guard: `bluxq guard policy link --doctrine main`
- Lite: `bluxq lite connect --doctrine`
- Commander: `bluxq commander panels enable --module doctrine`

## Operations
- Export doctrine: `bluxq doctrine export --output doctrine.yaml`
- Import updates: `bluxq doctrine import --file doctrine.yaml`
- Lock/unlock: `bluxq doctrine lock`, `bluxq doctrine unlock`

## Security
- Requires multi-signer approvals.
- Telemetry includes doctrine digests for traceability.

## Configuration
- YAML: `config/doctrine.yaml`
- ENV: `BLUX_DOCTRINE_PATH`

## Troubleshooting
- Approval delays: `bluxq doctrine approvals list`
- Drift detection: `bluxq doctrine diff`

## Source
Source: [blux-doctrine repository](https://github.com/Outer-Void/blux-doctrine)
