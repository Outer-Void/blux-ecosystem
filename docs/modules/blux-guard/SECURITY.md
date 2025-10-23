# BLUX GUARD SECURITY

> *Sentinel hardened for zero trust.*

## Threats
- Policy tampering.
- Unauthorized shell bypass.
- Telemetry forgery.

## Mitigations
- Doctrine-signed policy bundles.
- Secure enclaves for shell agent.
- Reg-signed telemetry envelopes.

## Response
- Lock enforcement: `bluxq guard mode set observation`.
- Investigate: `bluxq guard audit --run <id>`.

## Source
Source: [blux-guard SECURITY](https://github.com/Outer-Void/blux-guard)
