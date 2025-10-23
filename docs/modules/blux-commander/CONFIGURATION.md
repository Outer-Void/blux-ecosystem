# BLUX COMMANDER CONFIGURATION

> *Compose dashboards and APIs declaratively.*

## YAML
```yaml
modules:
  commander:
    host: commander.blux.local
    tls:
      enabled: true
    dashboards:
      - name: operations
        widgets:
          - lite.workflows
          - guard.enforcement
```

## Environment Variables
- `BLUX_COMMANDER_HOST`
- `BLUX_COMMANDER_TLS`

## CLI
- `bluxq commander config show`
- `bluxq commander config set --key dashboards[0].name --value sre`

## Source
Source: [blux-commander CONFIGURATION](https://github.com/Outer-Void/blux-commander)
