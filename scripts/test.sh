#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
LIVE_MODE=false
[[ "${1:-}" == "--live" ]] && LIVE_MODE=true

printf 'Kósmos smoke tests\n\n'

for script in \
  "$ROOT_DIR/bin/kosmos" "$ROOT_DIR/install.sh" "$ROOT_DIR/uninstall.sh" \
  "$ROOT_DIR"/scripts/*.sh "$ROOT_DIR"/migrations/*.sh \
  "$ROOT_DIR"/config/raycast/scripts/*.sh \
  "$ROOT_DIR"/config/sketchybar/plugins/*.sh \
  "$ROOT_DIR/config/borders/bordersrc" "$ROOT_DIR/config/yabairc"; do
  bash -n "$script"
done
zsh -n "$ROOT_DIR/config/zsh/kosmos.zsh"
printf '✓ shell syntax\n'

if command -v luac >/dev/null 2>&1; then
  for lua_file in "$ROOT_DIR"/config/sketchybar/*.lua "$ROOT_DIR"/config/sketchybar/items/*.lua "$ROOT_DIR"/themes/*/*.lua; do
    luac -p "$lua_file"
  done
  luac -p "$ROOT_DIR/config/sketchybar/sketchybarrc"
  printf '✓ Lua syntax\n'
fi

git -C "$ROOT_DIR" diff --check
printf '✓ patch whitespace\n'

for raycast_script in "$ROOT_DIR"/config/raycast/scripts/*.sh; do
  grep -q '^# @raycast.schemaVersion 1$' "$raycast_script"
  grep -q '^# @raycast.title ' "$raycast_script"
  grep -q '^# @raycast.mode ' "$raycast_script"
done
printf '✓ Raycast metadata\n'

for theme_dir in "$ROOT_DIR"/themes/*; do
  [[ -d "$theme_dir" ]] || continue
  for theme_file in theme.conf palette.sh ghostty.conf tmux.conf starship.toml nvim.lua; do
    [[ -s "$theme_dir/$theme_file" ]]
  done
  KOSMOS_ROOT="$ROOT_DIR" /bin/bash -c 'source "$1/theme.conf"; [[ -n "$THEME_DISPLAY_NAME" && -f "$WALLPAPER" ]]' _ "$theme_dir"
  if command -v starship >/dev/null 2>&1; then
    TERM=xterm-256color STARSHIP_CONFIG="$theme_dir/starship.toml" starship prompt >/dev/null
  fi
done
printf '✓ theme packages\n'

if command -v tmux >/dev/null 2>&1; then
  tmux_socket="kosmos-test-$$"
  cleanup_tmux() { tmux -L "$tmux_socket" kill-server 2>/dev/null || true; }
  trap cleanup_tmux EXIT
  tmux -L "$tmux_socket" -f "$ROOT_DIR/config/tmux.conf" new-session -d -s validation
  [[ "$(tmux -L "$tmux_socket" show-option -gv prefix)" == "C-Space" ]]
  cleanup_tmux
  trap - EXIT
  printf '✓ tmux configuration\n'
fi

ghostty_binary=$(command -v ghostty 2>/dev/null || true)
if [[ -z "$ghostty_binary" && -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]]; then
  ghostty_binary=/Applications/Ghostty.app/Contents/MacOS/ghostty
fi
if [[ -n "$ghostty_binary" && -f "$HOME/.config/kosmos/ghostty-theme.conf" ]]; then
  "$ghostty_binary" +validate-config --config-file="$ROOT_DIR/config/ghostty/config"
  printf '✓ Ghostty configuration\n'
fi

if command -v nvim >/dev/null 2>&1 && [[ -f "$HOME/.config/kosmos/nvim.lua" ]]; then
  nvim --headless +qa
  printf '✓ Neovim startup\n'
fi

if $LIVE_MODE; then
  "$ROOT_DIR/scripts/doctor.sh"
fi

printf '\nAll Kósmos smoke tests passed.\n'
