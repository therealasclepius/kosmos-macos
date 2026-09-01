#!/bin/bash
set -euo pipefail

ROOT_DIR=${KOSMOS_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
target="$HOME/.config/yashiki"

# Existing user configuration is never replaced by an automatic migration.
if [[ -e "$target" || -L "$target" ]]; then
  exit 0
fi

mkdir -p "$HOME/.config"
ln -s "$ROOT_DIR/config/yashiki" "$target"
