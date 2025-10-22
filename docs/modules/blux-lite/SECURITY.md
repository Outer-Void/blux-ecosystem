# BLUX LITE SECURITY

> *Every workflow step is watched by doctrine eyes.*

## Threat Model
- Unauthorized workflow execution.
- Tampering with runner images.
- Telemetry spoofing.

## Controls
- Mandatory Guard approval for privileged stages (`bluxq guard approve`).
- Runner images signed by Reg and verified during rollout.
- TLS mutual auth between Lite services and other modules.

## Hardening Checklist
- Enable sandboxed runners via `config/modules/lite.yaml` -> `runner_pool.*.sandbox: true`.
- Rotate service tokens weekly using `bluxq reg service rotate`.
- Monitor Guard audit feed for anomalies.

## Incident Response
- Pause workflows: `bluxq lite pause --workflow <name>`.
- Export run history for forensics: `bluxq lite runs export --format json`.

## Source
Source: [blux-lite SECURITY](https://github.com/Outer-Void/blux-lite)
