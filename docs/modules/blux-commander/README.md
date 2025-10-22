# BLUX COMMANDER

> *The command bridge where operators see and steer.*

## Overview
BLUX Commander is the web dashboard and API aggregation layer. It surfaces telemetry, governance workflows, and control endpoints for the ecosystem.

## Quick Start
```bash
bluxq commander status
bluxq commander dashboards list
bluxq commander api list
```

## Architecture
- **API Gateway** — Proxies module APIs with Reg authentication.
- **Dashboard Engine** — Configurable panels for operations, governance, privacy.
- **WebSocket Hub** — Streams live telemetry from Lite, Guard, and cA.

## Integration
- Publish dashboards: `bluxq commander dashboards publish --module guard`
- Connect to Reg for identity: `bluxq commander auth sync`
- Enable CLI session recording: `bluxq commander connect`

## Operations
- Start: `bluxq commander service start`
- Health: `bluxq commander status --verbose`
- Logs: `bluxq commander logs --follow`

## Security
- Enforces mutual TLS and Guard policy gating.
- Supports delegated administration with Reg-signed tokens.

## Configuration
- YAML: `config/modules/commander.yaml`
- ENV: `BLUX_COMMANDER_HOST`, `BLUX_COMMANDER_TLS`

## Troubleshooting
- UI blank: `bluxq commander status --trace`
- API 401: `bluxq commander auth refresh`

## Source
Source: [blux-commander repository](https://github.com/Outer-Void/blux-commander)
