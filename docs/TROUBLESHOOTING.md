# TROUBLESHOOTING

> *When the stars flicker, recalibrate with calm.*

## Quick Diagnostics
| Symptom | Check | Remedy |
| --- | --- | --- |
| `bluxq` command hangs | Network path to modules | `bluxq quantum ping` or `pwsh -Command "bluxq quantum ping"` |
| Guard blocks deploy | Doctrine mismatch | `bluxq doctrine diff --run <id>` and request approval |
| Commander UI blank | API gateway unreachable | `bluxq commander status` and check `config/compose/ui.yml` |
| Reg key errors | Expired certificates | `bluxq reg keys rotate` and verify system clock |
| Lite workflows stuck | Pending Guard review | `bluxq lite queue list --pending` |

## Platform Notes
### Linux
- Ensure Docker daemon is running and user is part of `docker` group.
- Use `journalctl -u blux-*` for systemd managed services.

### macOS
- Grant Full Disk Access to terminal if Guard file watchers require it.
- Restart Docker Desktop after kernel updates.

### Windows / WSL2
- Run CLI commands inside WSL for consistent paths.
- Use PowerShell wrappers to interact with Windows services.

## CLI Debugging
```bash
# Enable verbose logging
BLUX_LOG_LEVEL=debug bluxq lite status

# Trace HTTP calls
bluxq commander status --trace
```

## Telemetry Verification
```bash
# Confirm metrics export
grep exporter config/telemetry.yaml
bluxq quantum telemetry check
```

## Documentation Sync Issues
- Run `python scripts/scan_subrepos.py` to regenerate module docs.
- Rebuild README tree with `python scripts/update_readme_filetree.py`.
- Re-render docs index via `python scripts/render_index_from_readme.py`.

## Link Warnings
- Execute `python scripts/lint_links.py` to review warnings.
- Update relative paths or add anchors as needed.

## Support Escalation
Consult [SUPPORT](SUPPORT.md) for contact paths. Provide command output, configuration snippets, and doctrine digests when escalating.
