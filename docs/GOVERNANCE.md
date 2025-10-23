# GOVERNANCE

> *Stewardship that keeps the constellation true.*

## Roles & Councils
| Role | Responsibilities | Rotation |
| --- | --- | --- |
| Ecosystem Steward | Owns roadmap alignment, approves major releases | Annual |
| Module Maintainer | Guards module quality, triages issues, coordinates docs | Semi-annual |
| Doctrine Custodian | Oversees policy changes and ethical reviews | Quarterly |
| Security Sentinel | Operates Guard, leads incident response drills | Quarterly |
| Community Liaison | Manages contributor onboarding, forums | Quarterly |

## Decision Gates
1. **Proposal** — RFC or GitHub Discussion raised with impact summary.
2. **Review** — Maintainers and Doctrine Custodian review technical and ethical considerations.
3. **Vote** — Governance council records decision in `governance.md` log.
4. **Execution** — Assigned maintainers deliver, referencing [CONTRIBUTING](CONTRIBUTING.md).
5. **Retrospective** — Documented in Commander governance dashboard.

## Meeting Cadence
- **Weekly Sync** — Maintainers share status, open blockers.
- **Monthly Council** — Approve doctrine updates, review telemetry reports.
- **Quarterly Summit** — Align roadmap, revisit principles, invite community feedback.

## Artifacts
- `docs/GOVERNANCE.md` — This charter.
- `docs/ROADMAP.md` — Strategic plan.
- Commander Governance Dashboard — Live metrics.
- Doctrine Ledger — Signed decisions.

## Compliance Alignment
- Map decisions to regulatory controls using `compliance/` playbooks.
- Capture approvals with `bluxq doctrine approve --proposal <id>`.

## Escalation Paths
- Operational incidents escalate to Security Sentinel.
- Ethical concerns escalate to Doctrine Custodian.
- Community issues escalate to Ecosystem Steward.

## Open Participation
Community contributions follow the [CONTRIBUTING](CONTRIBUTING.md) guide. Mentorship pairs new contributors with module maintainers.

## Change Log
Record governance decisions with `bluxq commander governance log --summary "..."` for traceability.
