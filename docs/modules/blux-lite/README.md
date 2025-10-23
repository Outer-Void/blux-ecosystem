# BLUX LITE

> *Orchestrates the pulse of autonomous workflows with doctrine as compass.*

## Overview
BLUX Lite is the orchestrator that coordinates workflows across the ecosystem. It schedules jobs, invokes Guard checkpoints, and relays advisory insights from BLUX cA. Lite is the control tower for resilience drills and stability modes.

## Quick Start
```bash
bluxq lite status
bluxq lite deploy --file workflows/resilience.yaml
bluxq lite run --workflow resilience --env stage
```

## Architecture
- **Workflow Engine** — Event-driven orchestrator executing YAML-defined flows.
- **Policy Hooks** — Every transition calls Guard and Doctrine before proceeding.
- **Telemetry Channel** — Emits OpenTelemetry spans annotated with doctrine digests.

## Integration
- Consumes Reg-issued service accounts defined in `config/modules/lite.yaml`.
- Publishes job events to Commander dashboards via WebSocket feed.
- Pulls advisory signals from cA to adjust branching logic.

## Operations (Runbook)
- Start: `bluxq lite service start`
- Stop: `bluxq lite service stop`
- Health: `bluxq lite status --verbose`
- Logs: `bluxq lite logs --follow`

## Security
- Enforces Guard interceptors on every workflow step.
- Supports stability modes: observation, guided, autonomous.
- Doctrine approvals required for privileged workflows (`bluxq doctrine approve`).

## Configuration
- YAML: `config/modules/lite.yaml`
- Key fields: `stability_mode`, `runner_pool`, `recovery_strategies`.
- ENV: `BLUX_LITE_HOST`, `BLUX_LITE_RUNNER_POOL`.

## Troubleshooting
- Stuck jobs: `bluxq lite queue list --pending`
- Failed Guard check: inspect `bluxq guard audit --run <id>`
- Telemetry gaps: confirm `bluxq quantum telemetry check`.

## Source
Source: [blux-lite repository](https://github.com/Outer-Void/blux-lite)
