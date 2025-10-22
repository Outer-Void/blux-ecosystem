# BLUX CA INTEGRATION GUIDE

> *Let conscience flow into every automation.*

## Prerequisites
- `bluxq` CLI installed.
- Access to Doctrine API and Guard endorsement endpoints.

## Steps
1. Register advisory channel:
   ```bash
   bluxq reg service create --module ca --name ca-advisor --scopes advise
   ```
2. Grant Guard permissions:
   ```bash
   bluxq guard policy grant --module ca --policy ethical-boundary
   ```
3. Subscribe Lite workflows:
   ```bash
   bluxq lite connect --advisor ca --workflow resilience
   ```
4. Enable Commander panels:
   ```bash
   bluxq commander panels enable --module ca
   ```

## Configuration
```yaml
modules:
  ca:
    reflection_depth: medium
    advisory_channels:
      - lite
      - commander
```

## Validation
- `bluxq ca advise --scenario smoke-test`
- `bluxq commander panels list --module ca`

## Source
Source: [blux-ca INTEGRATION](https://github.com/Outer-Void/blux-ca)
