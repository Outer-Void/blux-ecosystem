# BLUX GUARD

> *The sentinel cockpit where trust is enforced.*

## Overview
BLUX Guard delivers a developer security cockpit, terminal shell enforcement, and policy analytics. It enforces doctrine-aligned guardrails for every workflow, API call, and CLI command.

## Quick Start
```bash
bluxq guard status
bluxq guard policy list
bluxq guard audit --tail 50
```

## Architecture
- **Policy Engine** — Evaluates doctrine constraints in real time.
- **Terminal Shell** — Enforces command policies for developers.
- **Cockpit UI** — Surfaces enforcement metrics through Commander integration.

## Integration
- Connect Lite workflows: `bluxq lite connect --guard`
- Pair with Doctrine: `bluxq doctrine subscribe --module guard`
- Expose cockpit panels: `bluxq commander panels enable --module guard`

## Operations
- Start: `bluxq guard service start`
- Health: `bluxq guard status --verbose`
- Telemetry: `bluxq guard metrics --format json`

## Security
- Zero trust interceptors for CLI and API.
- Supports stability modes with observation/guided/autonomous toggles.

## Configuration
- YAML: `config/modules/guard.yaml`
- ENV: `BLUX_GUARD_HOST`, `BLUX_GUARD_ENFORCEMENT`

## Troubleshooting
- Shell denial: `bluxq guard explain --command "..."`
- Policy drift: `bluxq guard policy diff`

## Source
Source: [blux-guard repository](https://github.com/Outer-Void/blux-guard)
