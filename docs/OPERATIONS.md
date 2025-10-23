# OPERATIONS

> *Steady hands for living systems.*

## Runbook Overview
This playbook coordinates day-two operations across BLUX modules. Every command references the unified `bluxq` CLI.

## Daily Rituals
- `bluxq status` — summarize health from Lite, Guard, Commander.
- `bluxq guard audit --tail 100` — stream the latest policy decisions.
- `bluxq doctrine pulse` — verify doctrine digests align with expectations.
- `bluxq reg keys --list` — confirm signing keys remain valid.

## Weekly Cadence
1. Rotate non-production credentials through BLUX Reg.
2. Review Guard telemetry anomalies in Commander dashboards.
3. Rehearse failover using Lite orchestrated blue/green scenario packs.
4. Run `mkdocs build` to ensure documentation stays synchronized.

## Incident Response
| Phase | Action | Command |
| --- | --- | --- |
| Detect | Configure Commander alerts to page `#blux-ops` when Guard blocks critical paths. | `bluxq guard alerts watch` |
| Triage | Capture the failing workflow with Lite. | `bluxq lite capture --run <id>` |
| Contain | Freeze doctrine changes and lock Reg issuance. | `bluxq doctrine lock --reason incident-<id>` |
| Eradicate | Patch modules or revert workflow definitions. | `bluxq lite rollout --rollback <id>` |
| Recover | Validate SLOs via Commander, resume doctrine updates. | `bluxq doctrine unlock` |
| Learn | Publish post-incident review to Governance log. | `bluxq commander pir create --source incident-<id>` |

## Maintenance Windows
- Schedule using Lite runbooks: `bluxq lite window create --module commander --duration 30m`.
- Notify operators via Commander broadcast API.

## Telemetry & Logging
- All modules ship OpenTelemetry traces to the configured endpoint in `config/telemetry.yaml`.
- Use `bluxq quantum plugins` to confirm telemetry exporters are enabled.
- For PowerShell automation, wrap commands with `pwsh -Command` for WSL bridging.

## Backup & Restore
```bash
# Snapshot doctrine and registry
bluxq doctrine export --output backups/doctrine-$(date +%F).yaml
bluxq reg export --output backups/reg-$(date +%F).json

# Restore on demand
bluxq doctrine import --file backups/doctrine-2024-01-01.yaml
bluxq reg import --file backups/reg-2024-01-01.json
```

## Deployment Pipelines
- Use GitHub Actions `docs.yml` for documentation and `ci.yml` for services.
- Deploy Commander via container registries described in module docs.

## SLOs & SLAs
- Availability target: 99.5% for Lite & Guard; 99.9% for Reg.
- Recovery Time Objective: < 10 minutes for CLI operations, < 30 minutes for UI.
- Recovery Point Objective: < 5 minutes using Reg continuous signing logs.

## Contact
Operational support is handled via [SUPPORT](SUPPORT.md). Escalate to Governance when incidents cross policy thresholds.
