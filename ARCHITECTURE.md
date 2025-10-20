# Architecture

BLUX is a conversation between intelligences — a modular system of cooperating layers.

```mermaid
flowchart TB
  Hub[blux-ecosystem (Hub)]:::hub
  Lite[blux-lite (Orchestrator)]:::core
  CA[blux-ca (Conscious Layer)]:::core
  Guard[blux-guard (Security)]:::shield
  Reg[blux-reg (Identity/Keys)]:::identity
  Quantum[blux-quantum (CLI/TUI)]:::iface
  Commander[blux-commander (Web UI)]:::iface

  Hub --- Lite
  Hub --- CA
  Hub --- Guard
  Hub --- Reg
  Hub --- Quantum
  Hub --- Commander
  Lite <--> CA
  Lite <--> Guard
  Guard <--> Reg
  Quantum --> Lite
  Commander --> Lite

  classDef hub fill:#111,color:#fff,stroke:#444;
  classDef core fill:#1f2937,color:#fff,stroke:#3b82f6;
  classDef shield fill:#0f172a,color:#fff,stroke:#22c55e;
  classDef identity fill:#0a0a0a,color:#fff,stroke:#eab308;
  classDef iface fill:#111827,color:#fff,stroke:#a855f7;
```

## Inter‑Module Protocols

- **Identity & Trust:** `blux-reg` issues/validates keys; `blux-guard` enforces; all calls require signed manifests.
- **Execution & Audit:** `blux-lite` routes tasks; `blux-guard` sandboxes; append-only JSONL audits.
- **Reflection:** `blux-cA` enriches reasoning; feeds doctrine‑aligned insights back into routing.
- **Interfaces:** `blux-quantum` (CLI/TUI) and `blux-commander` (Web) are operator surfaces.

See also: [INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)

> *Not louder — only clearer.*  (( • ))
