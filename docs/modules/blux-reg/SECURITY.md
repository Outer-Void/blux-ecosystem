# BLUX REG SECURITY

> *Protect the keys that protect everything else.*

## Threats
- Key compromise.
- Capability escalation.
- Audit tampering.

## Mitigations
- Hardware security modules optional but recommended.
- Capability approvals require Governance sign-off.
- Audit logs replicated and signed by Guard.

## Response
- Immediate key revoke: `bluxq reg keys revoke --id <key>`
- Freeze capabilities: `bluxq reg capability freeze`

## Source
Source: [blux-reg SECURITY](https://github.com/Outer-Void/blux-reg)
