# Security & Trust Overview

**Principles**  
- Zero‑trust by default.  
- Immutable audits for every significant action.  
- Local‑first memory; remote inference allowed with local guardrails.

## Components

- **blux-reg:** cryptographic identity, issuance, rotation, revocation
- **blux-guard:** sandboxing (WASM/Docker/Firecracker), mTLS, policy gates, JSONL audits
- **blux-lite:** enforces doctrine checks before execution
- **blux-ca:** logs reflection rationale (no secrets), references audit IDs

## Audits

- Format: JSONL, signed with hub key  
- Default path: `~/.config/blux/audit/`  
- Rotation: size/time thresholds; optional cold‑storage offload

## Data Handling

- PII minimization  
- Redaction on export  
- GDPR/CCPA delete manifests recorded in audit

> *Integrity > approval; truth > comfort.*  (( • ))
