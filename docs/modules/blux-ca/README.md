# BLUX CA

> *Conscious advisory whispering doctrine-aligned insight.*

## Overview
BLUX cA (Conscious Advisor) provides reflective analysis, ethical reasoning, and recommendations that inform Lite workflows and Commander dashboards.

## Quick Start
```bash
bluxq ca status
bluxq ca advise --scenario resilience-drill
bluxq ca journal --tail 20
```

## Architecture
- **Observation Layer** — Ingests telemetry and doctrine context.
- **Reflection Engine** — Applies ethical heuristics and scenario modeling.
- **Advisory Output** — Streams recommendations to Commander and Lite.

## Integration
- Subscribe Lite workflows: `bluxq lite connect --advisor ca`.
- Link Doctrine for policy context: `bluxq doctrine subscribe --module ca`.
- Surface in Commander: `bluxq commander panels enable --module ca`.

## Operations (Runbook)
- Start: `bluxq ca service start`
- Health: `bluxq ca status --verbose`
- Journals: `bluxq ca journal --export advisors/latest.json`

## Security
- Guard enforces ethical boundary checks before advice is executed.
- Reg signs advisory outputs for non-repudiation.

## Configuration
- YAML: `config/modules/ca.yaml`
- Fields: `reflection_depth`, `playbook_bindings`, `telemetry_channels`.
- ENV: `BLUX_CA_HOST`, `BLUX_CA_REFLECTION_DEPTH`.

## Troubleshooting
- If recommendations stale: `bluxq ca refresh --source telemetry`.
- For doctrine mismatches: `bluxq doctrine diff --module ca`.

## Source
Source: [blux-ca repository](https://github.com/Outer-Void/blux-ca)
