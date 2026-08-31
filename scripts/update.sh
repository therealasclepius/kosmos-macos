#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
STATE_DIR="$HOME/.local/state/kosmos"
LOCK_DIR="$STATE_DIR/update.lock"

mkdir -p "$STATE_DIR"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  printf 'Another Kósmos update is already running.\n' >&2
  exit 1
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

if [[ -n "$(git -C "$ROOT_DIR" status --porcelain)" ]]; then
  printf 'Kósmos has local changes. Commit or stash them before updating.\n' >&2
  exit 1
fi

printf 'Creating pre-update configuration snapshot…\n'
KOSMOS_ROOT="$ROOT_DIR" "$ROOT_DIR/scripts/snapshot.sh" create pre-update

printf 'Updating Kósmos…\n'
git -C "$ROOT_DIR" pull --ff-only

printf 'Installing declared dependencies…\n'
brew bundle --file "$ROOT_DIR/Brewfile"

printf 'Running Kósmos migrations…\n'
"$ROOT_DIR/scripts/migrate.sh"

if [[ "${KOSMOS_UPGRADE_PACKAGES:-false}" == "true" ]]; then
  printf 'Upgrading Homebrew packages…\n'
  brew upgrade
fi

"$ROOT_DIR/scripts/restart.sh"
printf 'Kósmos is up to date.\n'
