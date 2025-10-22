# BLUX LITE CONFIGURATION

> *Tune orchestration through declarative manifests.*

## YAML Schema
```yaml
modules:
  lite:
    stability_mode: guided
    runner_pool:
      default:
        size: 3
        runtime: docker
        sandbox: true
    recovery_strategies:
      - name: restart
        retries: 3
```

## Environment Variables
- `BLUX_LITE_HOST`
- `BLUX_LITE_PORT`
- `BLUX_LITE_RUNNER_POOL`

PowerShell:
```powershell
$env:BLUX_LITE_HOST = "localhost"
```

## CLI Helpers
- `bluxq lite config show`
- `bluxq lite config diff --profile stage`

## Source
Source: [blux-lite CONFIGURATION](https://github.com/Outer-Void/blux-lite)
