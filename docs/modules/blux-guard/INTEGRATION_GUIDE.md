# BLUX GUARD INTEGRATION GUIDE

> *Embed enforcement into every interface.*

## Prerequisites
- Doctrine policies defined and approved.
- Reg capabilities for modules requiring enforcement.

## Steps
1. Provision Guard identity:
   ```bash
   bluxq reg service create --module guard --name guard-core --scopes enforce
   ```
2. Load policies:
   ```bash
   bluxq guard policy import --file policies/default.yaml
   ```
3. Attach to Lite workflows:
   ```bash
   bluxq lite connect --guard
   ```
4. Enable developer shell:
   ```bash
   bluxq guard shell install
   ```
5. Link Commander cockpit:
   ```bash
   bluxq commander panels enable --module guard
   ```

## Validation
- `bluxq guard policy list`
- `bluxq guard explain --command "docker run"`

## Source
Source: [blux-guard INTEGRATION](https://github.com/Outer-Void/blux-guard)
