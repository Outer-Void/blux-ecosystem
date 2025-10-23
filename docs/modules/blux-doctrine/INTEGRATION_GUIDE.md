# BLUX DOCTRINE INTEGRATION GUIDE

> *Wire doctrine into every decision loop.*

## Steps
1. Clone doctrine repo or sync submodule.
2. Configure CLI access:
   ```bash
   bluxq doctrine auth login --role custodian
   ```
3. Subscribe modules:
   ```bash
   bluxq guard policy link --doctrine main
   bluxq lite connect --doctrine
   bluxq ca context subscribe --doctrine main
   ```
4. Set Commander panels:
   ```bash
   bluxq commander panels enable --module doctrine
   ```

## Validation
- `bluxq doctrine pulse`
- `bluxq doctrine diff --since latest`

## Source
Source: [blux-doctrine INTEGRATION](https://github.com/Outer-Void/blux-doctrine)
