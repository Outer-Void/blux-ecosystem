# BLUX GUARD COMMANDS

> *Command the sentinel from `bluxq`.*

## CLI Commands
| Command | Description |
| --- | --- |
| `bluxq guard status` | Summaries enforcement posture |
| `bluxq guard policy list` | List policies |
| `bluxq guard policy import --file <file>` | Import policies |
| `bluxq guard audit --tail <n>` | Stream audit events |
| `bluxq guard explain --command <cmd>` | Explain enforcement decision |
| `bluxq guard mode set <mode>` | Switch enforcement mode |

## API Endpoints
| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/api/v1/policies` | Upload policy |
| GET | `/api/v1/audit` | Fetch audit feed |
| POST | `/api/v1/mode` | Set mode |

## Source
Source: [blux-guard API](https://github.com/Outer-Void/blux-guard)
