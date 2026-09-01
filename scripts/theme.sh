#!/bin/bash
set -euo pipefail

ROOT_DIR=${KOSMOS_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
THEMES_DIR="$ROOT_DIR/themes"
RUNTIME_DIR="$HOME/.config/kosmos"

usage() {
  printf 'Usage: kosmos theme list | current | set <name> [--no-wallpaper]\n'
}

atomic_copy() {
  local source_file=$1 destination_file=$2 temporary_file
  mkdir -p "$(dirname "$destination_file")"
  temporary_file=$(mktemp "$(dirname "$destination_file")/.kosmos-theme.XXXXXX")
  cp "$source_file" "$temporary_file"
  chmod 644 "$temporary_file"
  mv -f "$temporary_file" "$destination_file"
}

list_themes() {
  find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

current_theme() {
  if [[ -f "$RUNTIME_DIR/theme" ]]; then
    cat "$RUNTIME_DIR/theme"
  else
    printf 'osaka-jade\n'
  fi
}

apply_theme() {
  local theme_name=$1 wallpaper_enabled=${2:-true}
  local theme_dir="$THEMES_DIR/$theme_name"

  if [[ ! -d "$theme_dir" ]]; then
    printf 'Unknown theme: %s\nAvailable themes:\n' "$theme_name" >&2
    list_themes >&2
    exit 2
  fi

  export KOSMOS_ROOT="$ROOT_DIR"
  # shellcheck disable=SC1090
  source "$theme_dir/theme.conf"

  mkdir -p "$RUNTIME_DIR"
  atomic_copy "$theme_dir/palette.sh" "$RUNTIME_DIR/palette.sh"
  atomic_copy "$theme_dir/palette.lua" "$RUNTIME_DIR/palette.lua"
  atomic_copy "$theme_dir/ghostty.conf" "$RUNTIME_DIR/ghostty-theme.conf"
  atomic_copy "$theme_dir/tmux.conf" "$RUNTIME_DIR/tmux-theme.conf"
  atomic_copy "$theme_dir/starship.toml" "$RUNTIME_DIR/starship.toml"
  atomic_copy "$theme_dir/nvim.lua" "$RUNTIME_DIR/nvim.lua"
  printf '%s\n' "$theme_name" > "$RUNTIME_DIR/theme"

  defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
  defaults write NSGlobalDomain AppleAccentColor -int "$MACOS_ACCENT"

  if command -v sketchybar >/dev/null 2>&1 && pgrep -x sketchybar >/dev/null 2>&1; then
    sketchybar --reload
  fi
  if [[ -x "$HOME/.config/borders/bordersrc" ]]; then
    "$HOME/.config/borders/bordersrc"
  fi
  if tmux list-sessions >/dev/null 2>&1; then
    tmux source-file "$HOME/.tmux.conf"
  fi

  if [[ "$wallpaper_enabled" == "true" ]]; then
    "$ROOT_DIR/scripts/set-wallpaper.sh" "$WALLPAPER"
  fi

  osascript -e "display notification \"Theme changed to $THEME_DISPLAY_NAME\" with title \"Kósmos\"" 2>/dev/null || true
  printf 'Applied theme: %s\n' "$theme_name"
}

subcommand=${1:-list}
shift || true
case "$subcommand" in
  list) list_themes ;;
  current) current_theme ;;
  set)
    theme_name=${1:-}
    [[ -n "$theme_name" ]] || { usage >&2; exit 2; }
    shift || true
    wallpaper_enabled=true
    [[ "${1:-}" == "--no-wallpaper" ]] && wallpaper_enabled=false
    apply_theme "$theme_name" "$wallpaper_enabled"
    ;;
  *) usage >&2; exit 2 ;;
esac
