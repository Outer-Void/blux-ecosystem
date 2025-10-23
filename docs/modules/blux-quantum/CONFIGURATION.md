# BLUX QUANTUM CONFIGURATION

> *Shape the CLI experience.*

## YAML
```yaml
cli:
  context: stage
  output: table
  plugins:
    sources:
      - modules
      - registry
```

## Environment Variables
- `BLUX_CLI_CONTEXT`
- `BLUX_CLI_OUTPUT`

## CLI
- `bluxq quantum config show`
- `bluxq quantum config set --key output --value json`

## Source
Source: [blux-quantum CONFIGURATION](https://github.com/Outer-Void/blux-quantum)
