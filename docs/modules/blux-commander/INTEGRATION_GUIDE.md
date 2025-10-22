# BLUX COMMANDER INTEGRATION GUIDE

> *Wire your estate into the command bridge.*

## Steps
1. Provision identity:
   ```bash
   bluxq reg service create --module commander --name commander-gateway --scopes api
   ```
2. Configure TLS endpoints in `config/modules/commander.yaml`.
3. Register dashboards:
   ```bash
   bluxq commander dashboards publish --file dashboards/core.yaml
   ```
4. Enable API proxying for modules:
   ```bash
   bluxq commander api enable --module guard
   bluxq commander api enable --module lite
   ```
5. Sync user roles via Reg groups.

## Validation
- `bluxq commander status`
- `bluxq commander dashboards list`

## Source
Source: [blux-commander INTEGRATION](https://github.com/Outer-Void/blux-commander)
