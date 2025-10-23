# BLUX LITE INTEGRATION GUIDE

> *Thread Lite into your fabric without fray.*

## Overview
This guide explains how to connect BLUX Lite to surrounding services within the ecosystem and enterprise landscape.

## Prerequisites
- BLUX Reg access with capability `lite:orchestrate`.
- Guard policies granting workflow execution rights.
- Doctrine manifests defining allowed workflows.

## Steps
1. **Configure Identity** — Register Lite runners:
   ```bash
   bluxq reg service create --module lite --name lite-runner --scopes orchestrate
   ```
2. **Define Workflows** — Commit YAML to `workflows/` with doctrine tags.
3. **Set Config** — Update `config/modules/lite.yaml` with runner pools and stability mode.
4. **Validate** —
   ```bash
   bluxq lite validate --file workflows/resilience.yaml
   ```
5. **Deploy** —
   ```bash
   bluxq lite deploy --file workflows/resilience.yaml --env prod
   ```

## Integration Points
- **Guard**: `bluxq guard policy link --workflow resilience`
- **Doctrine**: `bluxq doctrine attest --workflow resilience`
- **Commander**: `bluxq commander dashboards publish --module lite`

## Configuration Example
```yaml
modules:
  lite:
    stability_mode: guided
    runner_pool:
      default:
        size: 5
        runtime: docker
```

## Testing
- Dry run workflows with `bluxq lite run --workflow <name> --dry-run`.
- Use Commander staging dashboards for integration verification.

## Source
Source: [blux-lite INTEGRATION GUIDE](https://github.com/Outer-Void/blux-lite/blob/main/INTEGRATION_GUIDE.md)
