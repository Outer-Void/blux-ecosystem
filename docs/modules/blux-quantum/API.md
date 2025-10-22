# BLUX QUANTUM COMMANDS

> *Master the `bluxq` interface.*

## Core Commands
| Command | Description |
| --- | --- |
| `bluxq help` | Display help |
| `bluxq modules list` | List installed module packs |
| `bluxq quantum plugins sync` | Sync plugins |
| `bluxq quantum doctor` | Diagnose CLI |
| `bluxq quantum auth login` | Authenticate |
| `bluxq quantum completions <shell>` | Generate completions |

## Module Invocation Pattern
```bash
bluxq <module> <command> [options]
```
Example:
```bash
bluxq guard policy list --format json
```

## Source
Source: [blux-quantum CLI](https://github.com/Outer-Void/blux-quantum)
