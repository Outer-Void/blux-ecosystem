# BLUX CA CONFIGURATION

> *Calibrate reflection depth and signal fidelity.*

## YAML Schema
```yaml
modules:
  ca:
    reflection_depth: medium
    telemetry_channels:
      - lite
      - guard
    doctrine_profiles:
      - ethics-default
```

## Environment Variables
- `BLUX_CA_HOST`
- `BLUX_CA_REFLECTION_DEPTH`

## CLI
- `bluxq ca config show`
- `bluxq ca config set --key reflection_depth --value deep`

## Source
Source: [blux-ca CONFIGURATION](https://github.com/Outer-Void/blux-ca)
