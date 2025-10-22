# BLUX CA OPERATIONS

> *Curate advisory loops with deliberate rhythm.*

## Lifecycle Commands
```bash
bluxq ca service start
bluxq ca service stop
bluxq ca status --verbose
```

## Journaling
- `bluxq ca journal --tail 50`
- Archive to S3 or equivalent via `bluxq ca journal --export s3://...`.

## Calibration
- Refresh doctrine context: `bluxq ca context sync`.
- Rebuild heuristics: `bluxq ca heuristics rebuild`.

## Incident Handling
- Suspend advisories: `bluxq ca suspend --reason incident-123`.
- Resume after review: `bluxq ca resume`.

## Metrics
- `bluxq ca metrics --format table`
- Commander panel: "Advisory Latency".

## Source
Source: [blux-ca OPERATIONS](https://github.com/Outer-Void/blux-ca)
