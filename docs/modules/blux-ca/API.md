# BLUX CA COMMANDS

> *Query the conscience through `bluxq`.*

## CLI Commands
| Command | Description |
| --- | --- |
| `bluxq ca status` | Health summary |
| `bluxq ca advise --scenario <name>` | Generate advisory package |
| `bluxq ca journal --tail <n>` | Stream reflections |
| `bluxq ca heuristics rebuild` | Recompute internal models |
| `bluxq ca suspend --reason <text>` | Pause advisories |

## API Endpoints
| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/api/v1/advice` | Request advisory |
| GET | `/api/v1/advice/{id}` | Retrieve results |
| POST | `/api/v1/heuristics/rebuild` | Trigger rebuild |

## Source
Source: [blux-ca API](https://github.com/Outer-Void/blux-ca)
