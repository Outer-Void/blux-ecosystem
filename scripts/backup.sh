#!/usr/bin/env bash
set -euo pipefail; IFS=$'\n\t'
TAG="${1:---tag backup-$(date +%F-%H%M%S)}"
OUT="backups/${TAG#--tag }"
mkdir -p "$OUT"
git ls-files -z | xargs -0 -I{} sh -c 'mkdir -p "$(dirname "'"$OUT"'"/{})"; cp "{}" "'"$OUT"'"/{}'
echo "backup at: $OUT"
