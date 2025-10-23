# CONFIGURATION

> *Shape the constellation with a single schema.*

## Overview
BLUX configuration is expressed through YAML manifests stored under `config/`. Each module consumes a namespaced section validated by shared schemas.

## Core Files
| File | Description |
| --- | --- |
| `config/blux.yaml` | Global toggles, organization metadata, stability mode defaults |
| `config/telemetry.yaml` | Observability exporters, sampling strategies |
| `config/credentials.yaml` | References to Reg-issued secrets |
| `config/compose/*.yml` | Container orchestrations for environments |
| `config/modules/*.yaml` | Module-specific overrides |

## Schema Snippet
```yaml
version: 1
organization:
  name: "Outer Void"
  tenancy: "multi"
telemetry:
  exporters:
    - name: otlp
      endpoint: https://telemetry.blux.local/v1/traces
      auth: reg-capability:telemetry-writer
modules:
  lite:
    stability_mode: guided
  guard:
    enforcement:
      developer_shell: true
  commander:
    dashboards:
      - name: resilience
        widgets:
          - guard.policy.status
          - lite.workflow.health
```

## Environment Variables
| Variable | Purpose |
| --- | --- |
| `BLUX_ENV` | Environment name (dev/stage/prod) |
| `BLUX_TELEMETRY_ENDPOINT` | Overrides OTLP endpoint |
| `BLUX_REG_HOST` | Points CLI to registry |
| `BLUX_GUARD_ENFORCEMENT` | Forces guard enforcement level |
| `BLUX_DOCTRINE_PATH` | Local doctrine manifest location |

PowerShell equivalents:
```powershell
$env:BLUX_ENV = "dev"
$env:BLUX_TELEMETRY_ENDPOINT = "https://telemetry.blux.local/v1/traces"
```

## Validation
- Run `python tools/config-validator.py` (if present) before deployments.
- `scripts/scan_subrepos.py` ensures module docs reflect configuration keys.

## Secrets Management
- Store secrets in Reg-managed stores; reference them by capability ID within YAML.
- Use `bluxq reg secret put` to update values without exposing them in plaintext.

## Overrides & Profiles
- Compose environment overlays using `config/profiles/<env>.yaml`.
- Merge with `bluxq config merge --profile stage`.

## Related Documents
- [OPERATIONS](OPERATIONS.md)
- [SECURITY](SECURITY.md)
- Module-specific configuration guides under `docs/modules/*/CONFIGURATION.md`.
