# BLUX DOCTRINE SECURITY

> *Doctrine integrity is non-negotiable.*

## Threats
- Unauthorized doctrine edits.
- Compromised custodian credentials.
- Replay attacks on manifests.

## Mitigations
- Multi-signer approvals enforced by Guard.
- Reg-signed manifests with monotonic version counters.
- Audit ledger replicated to secure storage.

## Response
- Lock doctrine: `bluxq doctrine lock`
- Rotate custodian keys: `bluxq reg keys rotate --role custodian`

## Source
Source: [blux-doctrine SECURITY](https://github.com/Outer-Void/blux-doctrine)
