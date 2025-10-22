# ARCHITECTURE

> *Convergence of conscience, command, and code.*

## Ecosystem Topology
```mermaid
graph TD
    subgraph Identity & Trust
        REG[BLUX Reg]\nKey Ledger
        DOCTRINE[BLUX Doctrine]\nPolicy Spine
    end
    subgraph Intelligence Loop
        CA[BLUX cA]\nConscious Advisor
        LITE[BLUX Lite]\nOrchestration Mesh
        GUARD[BLUX Guard]\nZero-Trust Sentinel
    end
    subgraph Experience
        COMMANDER[BLUX Commander]\nOperator Portal
        QUANTUM[BLUX Quantum]\nbluxq CLI
    end

    REG --> GUARD
    REG --> COMMANDER
    DOCTRINE --> GUARD
    DOCTRINE --> CA
    CA --> LITE
    LITE --> GUARD
    LITE --> COMMANDER
    GUARD --> COMMANDER
    QUANTUM --> LITE
    QUANTUM --> GUARD
    QUANTUM --> CA
    QUANTUM --> COMMANDER
```

## Data & Control Flows
- **Identity Lineage** — BLUX Reg signs service and operator identities, distributing capability manifests to Guard and Commander.
- **Doctrine Pulse** — Doctrine exposes a policy API consumed by Guard for enforcement, Lite for orchestration gating, and cA for ethical framing.
- **Advisory Loop** — cA monitors telemetry streams, generates situational recommendations, and exposes them via Commander panels and bluxq feeds.
- **Operational Mesh** — Lite coordinates workflows across modules, invoking Guard hooks and Doctrine validation before executing actions.
- **Experience Channel** — Commander visualizes state and exposes APIs, while bluxq offers command-line parity.

## Module Responsibilities
| Module | Purpose | Primary Interfaces |
| --- | --- | --- |
| BLUX Lite | Orchestration and job lifecycle control | gRPC jobs API, `bluxq lite *`, Guard policy hooks |
| BLUX cA | Conscious advisory reasoning | `bluxq ca *`, Doctrine policy evaluation, telemetry streams |
| BLUX Guard | Developer security cockpit and terminal enforcement | `bluxq guard *`, Commander dashboards, Reg capability checks |
| BLUX Quantum | Unified CLI (`bluxq`) and plugin host | Terminal, automation pipelines, module command packs |
| BLUX Doctrine | Doctrine policy engine and audits | REST policy API, Doctrine manifests, Guard enforcement |
| BLUX Commander | Web dashboard & API aggregation | HTTPS dashboard, WebSocket telemetry, Admin API |
| BLUX Reg | Identity, signing, and capability registry | Certificate authority, signing service, CLI key ops |

## Module Documentation Index
<!-- MODULE-DOCS:BEGIN -->
| Module | README | Architecture | Integration | Operations | Security | Configuration | API/Commands |
| --- | --- | --- | --- | --- | --- | --- | --- |
| BLUX Lite | [Link](modules/blux-lite/README.md) | [Link](modules/blux-lite/ARCHITECTURE.md) | [Link](modules/blux-lite/INTEGRATION_GUIDE.md) | [Link](modules/blux-lite/OPERATIONS.md) | [Link](modules/blux-lite/SECURITY.md) | [Link](modules/blux-lite/CONFIGURATION.md) | [Link](modules/blux-lite/API.md) |
| BLUX cA | [Link](modules/blux-ca/README.md) | [Link](modules/blux-ca/ARCHITECTURE.md) | [Link](modules/blux-ca/INTEGRATION_GUIDE.md) | [Link](modules/blux-ca/OPERATIONS.md) | [Link](modules/blux-ca/SECURITY.md) | [Link](modules/blux-ca/CONFIGURATION.md) | [Link](modules/blux-ca/API.md) |
| BLUX Guard | [Link](modules/blux-guard/README.md) | [Link](modules/blux-guard/ARCHITECTURE.md) | [Link](modules/blux-guard/INTEGRATION_GUIDE.md) | [Link](modules/blux-guard/OPERATIONS.md) | [Link](modules/blux-guard/SECURITY.md) | [Link](modules/blux-guard/CONFIGURATION.md) | [Link](modules/blux-guard/API.md) |
| BLUX Quantum (CLI) | [Link](modules/blux-quantum/README.md) | [Link](modules/blux-quantum/ARCHITECTURE.md) | [Link](modules/blux-quantum/INTEGRATION_GUIDE.md) | [Link](modules/blux-quantum/OPERATIONS.md) | [Link](modules/blux-quantum/SECURITY.md) | [Link](modules/blux-quantum/CONFIGURATION.md) | [Link](modules/blux-quantum/API.md) |
| BLUX Doctrine | [Link](modules/blux-doctrine/README.md) | [Link](modules/blux-doctrine/ARCHITECTURE.md) | [Link](modules/blux-doctrine/INTEGRATION_GUIDE.md) | [Link](modules/blux-doctrine/OPERATIONS.md) | [Link](modules/blux-doctrine/SECURITY.md) | [Link](modules/blux-doctrine/CONFIGURATION.md) | [Link](modules/blux-doctrine/API.md) |
| BLUX Commander | [Link](modules/blux-commander/README.md) | [Link](modules/blux-commander/ARCHITECTURE.md) | [Link](modules/blux-commander/INTEGRATION_GUIDE.md) | [Link](modules/blux-commander/OPERATIONS.md) | [Link](modules/blux-commander/SECURITY.md) | [Link](modules/blux-commander/CONFIGURATION.md) | [Link](modules/blux-commander/API.md) |
| BLUX Reg | [Link](modules/blux-reg/README.md) | [Link](modules/blux-reg/ARCHITECTURE.md) | [Link](modules/blux-reg/INTEGRATION_GUIDE.md) | [Link](modules/blux-reg/OPERATIONS.md) | [Link](modules/blux-reg/SECURITY.md) | [Link](modules/blux-reg/CONFIGURATION.md) | [Link](modules/blux-reg/API.md) |
<!-- MODULE-DOCS:END -->

## Control Planes
- **Execution Plane** — Jobs executed through Lite with Guard interceptors.
- **Policy Plane** — Doctrine schemas, Guard rule packs, Reg capabilities.
- **Experience Plane** — Commander UI, API surfaces, CLI surfaces.

## Observability & Telemetry
- All modules emit OpenTelemetry traces with Doctrine context tags.
- Guard enforces signed telemetry envelopes before data leaves the mesh.
- Commander displays consolidated SLO dashboards sourced from Lite and Reg metrics feeds.

## Integration Contracts
- Configuration expressed in YAML under `config/` with schema validated by `scripts/scan_subrepos.py` cross-checks.
- CLI interactions converge on `bluxq`, pulling module plugins from BLUX Quantum's manifest.

## Change Management
- Architectural changes require updates to this map, module docs, and the Doctrine changelog pointer.
- GitHub Discussions capture RFCs; accepted changes trigger the docs automation workflow.
