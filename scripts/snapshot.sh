#!/bin/bash
set -euo pipefail

ROOT_DIR=${KOSMOS_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
STATE_DIR="$HOME/.local/state/kosmos"
SNAPSHOT_DIR="$STATE_DIR/snapshots"

usage() {
  printf 'Usage: kosmos snapshot create | list | restore <archive> --yes\n'
}

create_snapshot() {
  local reason=${1:-manual} safe_reason timestamp archive metadata
  local candidate relative_path
  local -a included_paths=()
  timestamp=$(date +%Y%m%d-%H%M%S)
  safe_reason=$(printf '%s' "$reason" | tr -cs '[:alnum:]_-' '-')
  safe_reason=${safe_reason#-}
  safe_reason=${safe_reason%-}
  [[ -n "$safe_reason" ]] || safe_reason=manual
  mkdir -p "$SNAPSHOT_DIR"
  archive="$SNAPSHOT_DIR/$timestamp-$safe_reason.tar.gz"
  metadata="$SNAPSHOT_DIR/$timestamp-$safe_reason.txt"
  if [[ -e "$archive" ]]; then
    archive="$SNAPSHOT_DIR/$timestamp-$safe_reason-$$.tar.gz"
    metadata="$SNAPSHOT_DIR/$timestamp-$safe_reason-$$.txt"
  fi

  for relative_path in \
    .yabairc .skhdrc .tmux.conf .zshrc \
    .config/yabai .config/sketchybar .config/borders .config/nvim \
    .config/yazi .config/ghostty .config/kosmos .config/starship.toml; do
    candidate="$HOME/$relative_path"
    if [[ -e "$candidate" || -L "$candidate" ]]; then
      included_paths+=("$relative_path")
    fi
  done

  if (( ${#included_paths[@]} == 0 )); then
    printf 'No Kósmos configuration files found.\n' >&2
    exit 1
  fi

  # Archive managed links as links. Following them could make a restore write
  # through a live symlink into the Kósmos repository.
  tar -czf "$archive" -C "$HOME" "${included_paths[@]}"
  {
    printf 'created=%s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')"
    printf 'reason=%s\n' "$reason"
    printf 'kosmos_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD 2>/dev/null || printf unknown)"
    printf 'macos=%s\n' "$(sw_vers -productVersion)"
    printf 'theme=%s\n' "$(cat "$HOME/.config/kosmos/theme" 2>/dev/null || printf unknown)"
  } > "$metadata"

  printf '%s\n' "$archive"
}

list_snapshots() {
  mkdir -p "$SNAPSHOT_DIR"
  find "$SNAPSHOT_DIR" -maxdepth 1 -name '*.tar.gz' -type f -print | sort -r
}

restore_snapshot() {
  local archive=${1:-} confirmation=${2:-}
  [[ -f "$archive" ]] || { printf 'Snapshot not found: %s\n' "$archive" >&2; exit 2; }
  [[ "$confirmation" == "--yes" ]] || {
    printf 'Restoring overwrites managed configuration. Re-run with --yes.\n' >&2
    exit 2
  }

  create_snapshot pre-restore >/dev/null
  tar -xzf "$archive" -C "$HOME"
  "$ROOT_DIR/scripts/restart.sh"
  printf 'Restored snapshot: %s\n' "$archive"
}

subcommand=${1:-list}
shift || true
case "$subcommand" in
  create) create_snapshot "${1:-manual}" ;;
  list) list_snapshots ;;
  restore) restore_snapshot "${1:-}" "${2:-}" ;;
  *) usage >&2; exit 2 ;;
esac
