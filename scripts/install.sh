#!/usr/bin/env bash
set -euo pipefail; IFS=$'\n\t'
echo "[hub] installing helpers..."
chmod +x ./scripts/*.sh || true
echo "[hub] done."
