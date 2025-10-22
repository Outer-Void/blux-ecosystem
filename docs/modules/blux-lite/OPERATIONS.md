# BLUX LITE OPERATIONS

> *Keep orchestration smooth even during turbulence.*

## Overview
Operational guide for running BLUX Lite in production and staging environments.

## Start/Stop
```bash
bluxq lite service start
bluxq lite service stop
```
PowerShell:
```powershell
bluxq lite service start
```

## Health Checks
- `bluxq lite status --format table`
- `bluxq lite health --probe readiness`

## Logs & Telemetry
- `bluxq lite logs --follow`
- Ship logs to telemetry exporter defined in `config/telemetry.yaml`.

## Backups
```bash
bluxq lite export --output backups/lite-$(date +%F).yaml
```
Restore with `bluxq lite import --file backups/lite-<date>.yaml`.

## Upgrades
1. Freeze doctrine changes: `bluxq doctrine lock`.
2. Deploy new runners: `bluxq lite rollout --artifact <tag>`.
3. Monitor Guard approvals.
4. Unlock doctrine once stable.

## Rollback
```bash
bluxq lite rollout --rollback <deployment-id>
```

## Alerts
- Configure thresholds in Commander operations board.
- Use Guard to escalate severe policy blocks.

## Source
Source: [blux-lite OPERATIONS](https://github.com/Outer-Void/blux-lite)
