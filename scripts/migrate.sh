#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
STATE_DIR="$HOME/.local/state/kosmos"
MIGRATION_STATE="$STATE_DIR/migrations"
mkdir -p "$STATE_DIR"
touch "$MIGRATION_STATE"

for migration_file in "$ROOT_DIR"/migrations/*.sh; do
  [[ -f "$migration_file" ]] || continue
  migration_name=$(basename "$migration_file")
  if grep -Fqx "$migration_name" "$MIGRATION_STATE"; then
    continue
  fi

  printf 'Running migration %s\n' "$migration_name"
  KOSMOS_ROOT="$ROOT_DIR" /bin/bash "$migration_file"
  printf '%s\n' "$migration_name" >> "$MIGRATION_STATE"
done
