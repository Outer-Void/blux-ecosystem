# BLUX REG

> *Identity forge and capability ledger.*

## Overview
BLUX Reg manages identities, signing keys, and capability manifests for the ecosystem. It anchors trust for Guard, Commander, Lite, and CLI usage.

## Quick Start
```bash
bluxq reg status
bluxq reg keys list
bluxq reg capability list
```

## Architecture
- **CA Core** — Issues certificates and tokens.
- **Capability Store** — Tracks what each module can do.
- **Audit Ledger** — Records issuance and revocation events.

## Integration
- Provision service accounts: `bluxq reg service create`
- Rotate keys: `bluxq reg keys rotate`
- Link to Commander for access requests: `bluxq commander api enable --module reg`

## Operations
- Start: `bluxq reg service start`
- Health: `bluxq reg status --verbose`
- Logs: `bluxq reg audit --tail 100`

## Security
- Hardware-backed key storage recommended.
- Guard verifies capabilities before allowing actions.

## Configuration
- YAML: `config/modules/reg.yaml`
- ENV: `BLUX_REG_HOST`, `BLUX_REG_TOKEN_TTL`

## Troubleshooting
- Revocation not propagating: `bluxq reg cache flush`
- CLI auth issues: `bluxq quantum auth refresh`

## Source
Source: [blux-reg repository](https://github.com/Outer-Void/blux-reg)
