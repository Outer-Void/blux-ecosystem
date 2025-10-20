#!/usr/bin/env bash
set -euo pipefail; IFS=$'\n\t'
command -v rg >/dev/null 2>&1 && rg -n "AN(C|CH)HOR" || grep -Rni "ANCHOR" || true
