# Configuration

BLUX Ecosystem uses environment variables for secrets and paths.

## Environment

```bash
# Core
BLUX_ENV=development            # development|staging|production
BLUX_AUDIT_PATH=$HOME/.config/blux/audit/
BLUX_LOG_PATH=$HOME/.config/blux/logs/

# Services
BLUX_REG_HOST=localhost
BLUX_REG_PORT=50050
BLUX_GUARD_HOST=localhost
BLUX_GUARD_PORT=50052
BLUX_LITE_HOST=localhost
BLUX_LITE_PORT=50051
BLUX_CA_HOST=localhost
BLUX_CA_PORT=50053

# Observability
JAEGER_ENDPOINT=http://localhost:14268/api/traces
```

## Manifests

- `deploy/hub.manifest.json` — static hub metadata (keys, endpoints, versions)
- `deploy/policy.doctrine.json` — active doctrine flags for runtime checks

> *Configuration is choreography.*  (( • ))
