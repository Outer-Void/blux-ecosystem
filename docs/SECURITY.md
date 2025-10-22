# SECURITY

> *Trust is engineered, not assumed.*

## Threat Model
| Layer | Threats | Mitigations |
| --- | --- | --- |
| Identity (BLUX Reg) | Key theft, impersonation | Hardware-backed signing, short-lived capability tokens, audit log replication |
| Policy (BLUX Doctrine) | Unauthorized doctrine change, drift | Multi-signer approvals, doctrine lock, checksum verification via `bluxq doctrine pulse` |
| Execution (BLUX Lite) | Workflow tampering, privilege escalation | Guard interceptors, sandboxed runners, signed workflow manifests |
| Advisory (BLUX cA) | Prompt injection, hallucinated actions | Doctrine-aligned reflection checks, Guard gating, telemetry scoring |
| Surface (Commander & bluxq) | Session hijack, CLI misuse | Mutual TLS, device binding, command recording |

## Defensive Posture
- **Zero Trust** — Each module authenticates via BLUX Reg issued identities.
- **Immutable Telemetry** — Guard notarizes event logs; Doctrine cross-checks for policy compliance.
- **Secure Defaults** — Services start in stability mode with limited automation until doctrine approves expansion.

## Stability Modes
| Mode | Description | Activation |
| --- | --- | --- |
| Observation | Read-only posture capturing telemetry | `bluxq guard mode set observation` |
| Guided | Execute only doctrine-approved playbooks | `bluxq lite mode set guided` |
| Autonomous | Full automation with continuous guardrails | `bluxq lite mode set autonomous` (requires governance approval) |

## Telemetry
- Use `config/telemetry.yaml` to configure exporters (OTLP/HTTP, Kafka, Filesystem).
- All logs include doctrine digest and capability fingerprint.

## Incident Reporting
- Report vulnerabilities via [SECURITY.md](../SECURITY.md).
- Use `bluxq guard incident report --source <module>` to file internal tickets.

## Secure Development Lifecycle
1. Design review referencing this document and module-specific security guides.
2. Implementation must include Guard policy updates and Doctrine alignment tests.
3. Deployment requires Reg-signed release manifests.
4. Post-release monitoring via Commander dashboards.

## Dependencies
Run `pip install -r requirements-security.txt` (if present) to audit dependencies. Integrate results into `security.yml` workflow.

## References
- [BLUX Guard Security Guide](modules/blux-guard/SECURITY.md)
- [BLUX Doctrine Policy Reference](modules/blux-doctrine/README.md)
- [PRIVACY](PRIVACY.md)
