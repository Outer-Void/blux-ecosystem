# BLUX DOCTRINE OPERATIONS

> *Guard the principle ledger.*

## Lifecycle
```bash
bluxq doctrine service start
bluxq doctrine service stop
bluxq doctrine status --verbose
```

## Change Management
1. Draft proposal: `bluxq doctrine propose --file updates.yaml`
2. Review diffs: `bluxq doctrine diff --proposal <id>`
3. Collect signatures: `bluxq doctrine approve --proposal <id>`
4. Publish: `bluxq doctrine publish --proposal <id>`

## Backups
- `bluxq doctrine export --output backups/doctrine-$(date +%F).yaml`

## Incident Response
- Lock: `bluxq doctrine lock`
- Audit: `bluxq doctrine audit --tail 100`

## Source
Source: [blux-doctrine OPERATIONS](https://github.com/Outer-Void/blux-doctrine)
