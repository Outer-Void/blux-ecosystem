#!/usr/bin/env bash
set -euo pipefail; IFS=$'\n\t'
PATCH_FILE="${1:-}"
test -f "$PATCH_FILE" || { echo "usage: patch-apply.sh <patch>"; exit 1; }
patch -p1 < "$PATCH_FILE"
