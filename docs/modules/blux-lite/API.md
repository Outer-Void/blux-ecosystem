# BLUX LITE COMMANDS

> *Command the orchestrator with precision.*

## CLI Commands (`bluxq`)
| Command | Description |
| --- | --- |
| `bluxq lite status` | Summaries runner pools and active workflows |
| `bluxq lite deploy --file <path>` | Deploy workflow manifest |
| `bluxq lite run --workflow <name>` | Execute workflow |
| `bluxq lite pause --workflow <name>` | Pause workflow |
| `bluxq lite resume --workflow <name>` | Resume workflow |
| `bluxq lite queue list` | Inspect pending runs |
| `bluxq lite window create --module <module>` | Schedule maintenance |

## API Endpoints (if service mode enabled)
| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/api/v1/workflows` | Submit workflow manifest |
| GET | `/api/v1/workflows/{id}` | Retrieve workflow status |
| POST | `/api/v1/workflows/{id}:pause` | Pause workflow |
| POST | `/api/v1/workflows/{id}:resume` | Resume workflow |

## Telemetry Commands
- `bluxq lite metrics --format prometheus`
- `bluxq lite traces export`

## Source
Source: [blux-lite CLI](https://github.com/Outer-Void/blux-lite)
