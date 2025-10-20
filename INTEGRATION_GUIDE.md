# Integration Guide

## Sibling Repos

- Lite (Orchestrator): https://github.com/Outer-Void/blux-lite
- cA (Conscious Layer): https://github.com/Outer-Void/blux-ca
- Guard (Security): https://github.com/Outer-Void/blux-guard
- Reg (Identity/Keys): https://github.com/Outer-Void/blux-reg
- Quantum (CLI/TUI): https://github.com/Outer-Void/blux-quantum
- Commander (Web UI): https://github.com/Outer-Void/blux-commander

## Event Surfaces (examples)

- **TaskStart** → emitted by `blux-quantum` → consumed by `blux-lite`  
- **RouteDecision** → `blux-lite` → audited by `blux-guard` (+ signature)  
- **ReflectionNote** → `blux-ca` → linked to RouteDecision.audit_id  
- **KeyRotate** → `blux-reg` → broadcast to all services

## Minimal Local Dev Topology

- Single‑host dev (compose in future)
- Local gRPC between services
- Append‑only JSONL audits

> *Coordination births clarity.*  (( • ))
