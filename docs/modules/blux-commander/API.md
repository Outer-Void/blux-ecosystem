# BLUX COMMANDER API

> *Invoke the bridge programmatically.*

## CLI Commands
| Command | Description |
| --- | --- |
| `bluxq commander status` | Health |
| `bluxq commander dashboards list` | List dashboards |
| `bluxq commander api list` | Enumerate proxied APIs |
| `bluxq commander ws test` | Validate WebSocket |
| `bluxq commander governance log` | Record governance entry |

## REST API
| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/api/v1/dashboards` | Fetch dashboards |
| POST | `/api/v1/dashboards` | Publish dashboard |
| GET | `/api/v1/proxy/{module}` | Proxy module API |
| POST | `/api/v1/governance` | Create governance record |

## Source
Source: [blux-commander API](https://github.com/Outer-Void/blux-commander)
