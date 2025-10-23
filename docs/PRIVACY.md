# PRIVACY

> *Telemetry with consent, intelligence with discretion.*

## Scope
BLUX collects only the telemetry required for safe operation and doctrinal accountability. Personal data stays at the edge unless explicitly ingested for orchestration tasks.

## Data Classes
| Class | Description | Retention | Control |
| --- | --- | --- | --- |
| Operational Telemetry | Metrics, traces, audits | 30 days (configurable) | `config/telemetry.yaml` |
| Doctrine Manifests | Policy definitions, approvals | Versioned indefinitely | `bluxq doctrine export` |
| Identity Artifacts | Keys, certificates | Rotated per policy | `bluxq reg keys rotate` |
| User Preferences | Commander dashboard settings | 90 days | Commander profile settings |

## Consent & Transparency
- Operators can inspect telemetry contracts using `bluxq quantum privacy --module <name>`.
- Commander surfaces data usage dashboards aligned with Doctrine privacy tenets.

## Data Residency
- Configure storage endpoints per region using `config/privacy.yaml`.
- Support multi-region replication with Reg-signed audit trails.

## Access Controls
- Reg issues scoped capabilities for accessing privacy-protected datasets.
- Guard enforces classification-level policies before releasing telemetry.

## Data Subject Requests
1. Authenticate requester via Reg.
2. Run `bluxq commander dsar export --subject <id>`.
3. Review output for Doctrine exemptions.
4. Deliver encrypted bundle via approved channel.

## Anonymization & Redaction
- Use Lite data pipelines to redact PII before telemetry leaves secure zones.
- Doctrine enforces non-overridable redaction policies for sensitive fields.

## Auditability
- `bluxq privacy audit` exports a signed ledger of data access events.
- Align with [COMPLIANCE](../COMPLIANCE.md) obligations.

## Links
- [SECURITY](SECURITY.md)
- [CONFIGURATION](CONFIGURATION.md)
