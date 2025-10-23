# BLUX REG API

> *Issue, sign, revoke — from CLI or REST.*

## CLI Commands
| Command | Description |
| --- | --- |
| `bluxq reg status` | Health |
| `bluxq reg service create` | Provision service account |
| `bluxq reg keys list` | List keys |
| `bluxq reg keys rotate` | Rotate key |
| `bluxq reg capability list` | List capabilities |

## REST API
| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/api/v1/services` | Create service |
| POST | `/api/v1/keys/{id}/rotate` | Rotate key |
| GET | `/api/v1/capabilities` | List capabilities |

## Source
Source: [blux-reg API](https://github.com/Outer-Void/blux-reg)
