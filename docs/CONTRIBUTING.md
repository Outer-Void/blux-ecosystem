# CONTRIBUTING

> *Contribute with clarity; doctrine lights the path.*

## Start Here
- Read the root [CONTRIBUTING](../CONTRIBUTING.md) for repository-wide policies.
- Join the `#blux-builders` channel in Commander (if provisioned) for onboarding.

## Workflow Overview
1. Fork and branch from `main`.
2. Run `python scripts/scan_subrepos.py` to ensure docs stay in sync.
3. Implement changes with tests.
4. Update documentation in `/docs` and relevant module directories.
5. Execute `python scripts/update_readme_filetree.py` to refresh the tree.
6. Submit pull request referencing Doctrine principles.

## Commit Style
- Prefix doc-wide upgrades with `[ECOSYSTEM-DOCS]`.
- Reference module names when scoped (e.g., `[LITE]`).

## Code of Conduct
Honor the [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md) and escalate issues through Governance.

## Documentation Expectations
- Update module docs for affected components.
- Regenerate MkDocs site via `mkdocs build` before submission.

## Testing Expectations
- Run existing automation: `./scripts/health-check.sh`.
- For CLI modules, execute `bluxq <module> test` commands when available.

## Release Notes
Add entries to [ROADMAP](ROADMAP.md) or root `CHANGELOG.md` when relevant.

## Questions
Open GitHub Discussions or ping the Community Liaison.
