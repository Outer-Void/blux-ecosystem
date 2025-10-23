# BLUX DOCTRINE COMMANDS

> *Shape policy with command precision.*

## CLI
| Command | Description |
| --- | --- |
| `bluxq doctrine status` | Show doctrine summary |
| `bluxq doctrine propose --file <path>` | Create proposal |
| `bluxq doctrine approve --proposal <id>` | Approve change |
| `bluxq doctrine diff --proposal <id>` | View diff |
| `bluxq doctrine publish --proposal <id>` | Publish |

## API
| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/api/v1/doctrine` | Retrieve current doctrine |
| POST | `/api/v1/proposals` | Submit proposal |
| POST | `/api/v1/proposals/{id}/approve` | Approve |

## Source
Source: [blux-doctrine API](https://github.com/Outer-Void/blux-doctrine)
