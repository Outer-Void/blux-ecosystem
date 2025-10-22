# BLUX DOCTRINE CONFIGURATION

> *Declare principles in structured form.*

## YAML
```yaml
doctrine:
  default_profile: main
  custodians:
    - alice@outervoid
    - ben@outervoid
  approvals_required: 2
```

## Environment Variables
- `BLUX_DOCTRINE_PATH`
- `BLUX_DOCTRINE_PROFILE`

## CLI
- `bluxq doctrine config show`
- `bluxq doctrine config set --key approvals_required --value 3`

## Source
Source: [blux-doctrine CONFIGURATION](https://github.com/Outer-Void/blux-doctrine)
