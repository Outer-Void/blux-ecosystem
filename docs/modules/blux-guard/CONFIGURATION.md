# BLUX GUARD CONFIGURATION

> *Dial enforcement with precision.*

## YAML
```yaml
modules:
  guard:
    enforcement_level: guided
    cockpit:
      panels:
        - policy-overview
        - terminal-events
    shell:
      enabled: true
```

## Environment Variables
- `BLUX_GUARD_HOST`
- `BLUX_GUARD_ENFORCEMENT`

## CLI
- `bluxq guard config show`
- `bluxq guard config set --key enforcement_level --value autonomous`

## Source
Source: [blux-guard CONFIGURATION](https://github.com/Outer-Void/blux-guard)
