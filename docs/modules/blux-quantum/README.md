# BLUX QUANTUM (bluxq)

> *Single CLI to command the constellation.*

## Overview
BLUX Quantum delivers `bluxq`, the unified CLI across modules. It loads plugins, manages contexts, and exposes automation-friendly output formats.

## Quick Start
```bash
bluxq --version
bluxq help
bluxq modules list
```

## Architecture
- **Core Launcher** — Handles authentication, plugin discovery, telemetry.
- **Plugin Host** — Loads module command packs.
- **Transport Layer** — Connects to module APIs with Reg-authenticated sessions.

## Integration
- Install plugins from modules: `bluxq quantum plugins sync`
- Configure context: `bluxq quantum context set stage`
- Connect to Commander for command recording: `bluxq commander connect`

## Operations
- Update CLI: `bluxq quantum upgrade`
- Verify health: `bluxq quantum doctor`
- Generate shell completions: `bluxq quantum completions bash`

## Security
- Supports hardware-backed keys and Reg-signed tokens.
- Guard interceptors inspect every command invocation.

## Configuration
- YAML: `config/cli/bluxq.yaml`
- ENV: `BLUX_CLI_CONTEXT`, `BLUX_CLI_TELEMETRY`

## Troubleshooting
- Plugin missing: `bluxq quantum plugins list --verbose`
- Auth failure: `bluxq quantum auth refresh`

## Source
Source: [blux-quantum repository](https://github.com/Outer-Void/blux-quantum)
