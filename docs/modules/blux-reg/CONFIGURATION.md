# BLUX REG CONFIGURATION

> *Configure the forge with clarity.*

## YAML
```yaml
modules:
  reg:
    host: reg.blux.local
    token_ttl: 3600
    audit_replicas: 3
```

## Environment Variables
- `BLUX_REG_HOST`
- `BLUX_REG_TOKEN_TTL`

## CLI
- `bluxq reg config show`
- `bluxq reg config set --key token_ttl --value 600`

## Source
Source: [blux-reg CONFIGURATION](https://github.com/Outer-Void/blux-reg)
