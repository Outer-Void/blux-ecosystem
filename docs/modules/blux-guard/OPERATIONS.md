# BLUX GUARD OPERATIONS

> *Keep the sentinel vigilant.*

## Lifecycle
```bash
bluxq guard service start
bluxq guard service stop
bluxq guard status --verbose
```

## Auditing
- `bluxq guard audit --tail 100`
- Export to storage: `bluxq guard audit --export s3://blux-logs/guard.json`

## Policy Management
- Update: `bluxq guard policy import --file policies/update.yaml`
- Rollback: `bluxq guard policy rollback --version <id>`

## Alerts
- Configure thresholds: `bluxq guard alerts configure --policy high-risk`
- Watch stream: `bluxq guard alerts watch`

## Source
Source: [blux-guard OPERATIONS](https://github.com/Outer-Void/blux-guard)
