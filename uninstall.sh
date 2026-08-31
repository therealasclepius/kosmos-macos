#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
STATE_DIR="$HOME/.local/state/kosmos"

printf 'This removes Kósmos links and stops its services. Homebrew packages remain installed.\n'
printf 'Continue? [y/N] '
read -r answer
[[ "$answer" == "y" || "$answer" == "Y" ]] || exit 0

yabai --stop-service 2>/dev/null || true
skhd --stop-service 2>/dev/null || true
brew services stop sketchybar 2>/dev/null || true
brew services stop borders 2>/dev/null || true

remove_link() {
  local target=$1
  if [[ -L "$target" ]] && [[ $(readlink "$target") == "$ROOT_DIR"/* ]]; then
    unlink "$target"
    printf 'Removed %s\n' "$target"
  fi
}

remove_link "$HOME/.yabairc"
remove_link "$HOME/Pictures/Kosmos/osaka-jade-bg.jpg"
remove_link "$HOME/.config/yabai/yabairc"
remove_link "$HOME/.config/yabai/toggle-maximize.sh"
remove_link "$HOME/.skhdrc"
remove_link "$HOME/.tmux.conf"
remove_link "$HOME/.config/ghostty/config"
remove_link "$HOME/.config/sketchybar"
remove_link "$HOME/.config/borders"
remove_link "$HOME/.config/nvim"
remove_link "$HOME/.config/yazi"

if [[ -f "$STATE_DIR/latest-backup" ]]; then
  backup=$(<"$STATE_DIR/latest-backup")
  printf 'Your pre-install files remain in %s\n' "$backup"
fi
printf 'Kósmos removed. Homebrew packages and macOS preferences were left intact for safety.\n'
