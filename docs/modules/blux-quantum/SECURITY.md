# BLUX QUANTUM SECURITY

> *The CLI is the front door; guard it fiercely.*

## Risks
- Credential leakage.
- Plugin tampering.
- Downgrade attacks.

## Mitigations
- Uses Reg-issued tokens stored in OS keychain.
- Plugins signed and hashed; verify via `bluxq quantum plugins verify`.
- Guard intercepts for high-risk commands.

## Hardening
- Enable FIDO2 hardware keys via `bluxq quantum auth devices add`.
- Restrict plugin sources in `config/cli/bluxq.yaml`.

## Source
Source: [blux-quantum SECURITY](https://github.com/Outer-Void/blux-quantum)
