# BLUX QUANTUM INTEGRATION GUIDE

> *Adopt `bluxq` everywhere teams operate.*

## Installation
```bash
pip install bluxq  # or pip install -e ./blux-quantum
```

PowerShell:
```powershell
pip install bluxq
```

## Configure Context
```bash
bluxq quantum context set stage
bluxq quantum auth login --capability operator
```

## Plugin Sync
```bash
bluxq quantum plugins sync
bluxq quantum plugins list
```

## CI Integration
Add to pipelines:
```yaml
- name: Install bluxq
  run: pip install bluxq
- name: Validate workflows
  run: bluxq lite validate --file workflows/*.yaml
```

## Source
Source: [blux-quantum INTEGRATION](https://github.com/Outer-Void/blux-quantum)
