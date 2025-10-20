# Developer Guide — Patch‑First Workflow

We change the world gently: **diffs over rewrites**, **anchors over guesses**, **backups before edits**.

## Anchors

Use named anchors to localize edits:

```text
# ANCHOR: route_selection
# ANCHOR_END: route_selection
```

## Flow

1) **Branch**
```bash
git checkout -b feature/<short-name>
```

2) **Backup**
```bash
./scripts/backup.sh --tag before-<short-name>
```

3) **Edit within Anchors**  
Keep changes inside anchor blocks; avoid widening scope.

4) **Patch**
```bash
git diff > patches/$(date +%F)-<name>.patch
```

5) **PR**
```bash
gh pr create -t "feat: <short-name>" -b "Anchors: <list>"
```

> *Make each rewrite traceable.*  (( • ))
