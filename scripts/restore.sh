#!/usr/bin/env bash
set -euo pipefail; IFS=$'\n\t'
SRC="${1:-}"
test -d "$SRC" || { echo "usage: restore.sh <backup_dir>"; exit 1; }
rsync -a "$SRC"/ ./
