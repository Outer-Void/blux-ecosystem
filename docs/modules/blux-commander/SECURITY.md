# BLUX COMMANDER SECURITY

> *The bridge must be guarded.*

## Threats
- Session hijacking.
- API abuse.
- Dashboard tampering.

## Controls
- Mutual TLS with Reg-signed certs.
- Guard policy gating for admin actions.
- Content Security Policy for UI assets.

## Incident Response
- Force logout: `bluxq commander auth revoke --all`
- Lock dashboards: `bluxq commander dashboards lock`

## Source
Source: [blux-commander SECURITY](https://github.com/Outer-Void/blux-commander)
