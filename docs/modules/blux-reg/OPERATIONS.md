# BLUX REG OPERATIONS

> *Maintain the forge with vigilance.*

## Lifecycle
```bash
bluxq reg service start
bluxq reg service stop
bluxq reg status --verbose
```

## Key Management
- List keys: `bluxq reg keys list`
- Rotate: `bluxq reg keys rotate --id <key>`
- Revoke: `bluxq reg keys revoke --id <key>`

## Capability Management
- Grant: `bluxq reg capability grant --module commander --capability dashboards`
- Revoke: `bluxq reg capability revoke --module lite --capability orchestrate`

## Audit
- `bluxq reg audit --tail 100`
- Export: `bluxq reg audit --export backups/reg-audit.json`

## Source
Source: [blux-reg OPERATIONS](https://github.com/Outer-Void/blux-reg)
