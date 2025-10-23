# BLUX COMMANDER OPERATIONS

> *Sustain the bridge with calm precision.*

## Lifecycle
```bash
bluxq commander service start
bluxq commander service stop
bluxq commander status --verbose
```

## Deployments
- Container: `docker compose -f config/compose/commander.yml up -d`
- Helm (if provided): `helm upgrade --install blux-commander charts/commander`

## Monitoring
- `bluxq commander metrics --format json`
- WebSocket diagnostics: `bluxq commander ws test`

## Backups
- Export settings: `bluxq commander export --output backups/commander.json`

## Incident Response
- Enable maintenance mode: `bluxq commander mode maintenance --message "Upgrade"`
- Audit API calls: `bluxq commander audit --tail 100`

## Source
Source: [blux-commander OPERATIONS](https://github.com/Outer-Void/blux-commander)
