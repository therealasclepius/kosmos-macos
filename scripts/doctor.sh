#!/bin/bash
set -u

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
failures=0
warnings=0
check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    printf '✓ %-14s %s\n' "$1" "$(command -v "$1")"
  else
    printf '✗ %-14s missing\n' "$1"
    failures=$((failures + 1))
  fi
}

printf 'Kósmos system check\n\n'
for command in brew yabai skhd sketchybar borders tmux nvim yazi lazygit gh delta rg fd jq mise firecrawl \
  starship zoxide fzf eza bat tesseract zbarimg ffmpeg lua; do
  check_command "$command"
done

if [[ -d /Applications/CleanShot\ X.app ]]; then
  printf '✓ CleanShot X is installed\n'
else
  printf '✗ CleanShot X is missing\n'
  failures=$((failures + 1))
fi

if [[ -f "$HOME/.local/share/sketchybar_lua/sketchybar.so" ]]; then
  printf '✓ SbarLua module is installed\n'
else
  printf '✗ SbarLua module is missing\n'
  failures=$((failures + 1))
fi

printf '\nConfiguration\n'
for path in "$HOME/.yabairc" "$HOME/.config/yabai/yabairc" "$HOME/.skhdrc" "$HOME/.tmux.conf" \
  "$HOME/.config/yabai/toggle-maximize.sh" "$HOME/.config/ghostty/config" \
  "$HOME/.config/sketchybar" "$HOME/.config/borders" \
  "$HOME/.config/nvim" "$HOME/.config/yazi" "$HOME/.config/kosmos/shell.zsh" \
  "$HOME/.config/kosmos/palette.sh" "$HOME/.config/kosmos/ghostty-theme.conf" \
  "$HOME/.config/kosmos/tmux-theme.conf" "$HOME/.config/kosmos/starship.toml" \
  "$HOME/.config/kosmos/nvim.lua" "$HOME/.config/kosmos/palette.lua" \
  "$HOME/.local/bin/kosmos"; do
  if [[ -e "$path" || -L "$path" ]]; then
    printf '✓ %s\n' "$path"
  else
    printf '✗ %s\n' "$path"
    failures=$((failures + 1))
  fi
done

if [[ -f "$HOME/.config/kosmos/theme" ]]; then
  printf '✓ active theme: %s\n' "$(cat "$HOME/.config/kosmos/theme")"
else
  printf '✗ no active theme is recorded\n'
  failures=$((failures + 1))
fi

raycast_dir=${KOSMOS_RAYCAST_DIR:-"$HOME/Documents/Raycast Script Commands"}
raycast_count=$(find "$raycast_dir" -maxdepth 1 -name 'kosmos-*.sh' -type l 2>/dev/null | wc -l | tr -d ' ')
if (( raycast_count >= 8 )); then
  printf '✓ %s Kósmos commands are available in Raycast\n' "$raycast_count"
else
  printf '✗ Raycast Kósmos commands are incomplete (%s found)\n' "$raycast_count"
  failures=$((failures + 1))
fi

printf '\nServices\n'
if yabai -m query --spaces >/dev/null 2>&1; then
  printf '✓ yabai is responding\n'
else
  printf '✗ yabai is not responding\n'
  failures=$((failures + 1))
fi

if launchctl print "gui/$(id -u)/com.koekeishiya.skhd" 2>/dev/null | grep -q 'state = running'; then
  printf '✓ skhd is running\n'
else
  printf '✗ skhd is not running\n'
  failures=$((failures + 1))
fi

if sketchybar --query bar >/dev/null 2>&1; then
  printf '✓ SketchyBar is responding\n'
else
  printf '✗ SketchyBar is not responding\n'
  failures=$((failures + 1))
fi

for item_name in cpu memory volume; do
  if sketchybar --query "$item_name" >/dev/null 2>&1; then
    printf '✓ SketchyBar %s widget is responding\n' "$item_name"
  else
    printf '✗ SketchyBar %s widget is missing\n' "$item_name"
    failures=$((failures + 1))
  fi
done

if pgrep -x borders >/dev/null 2>&1; then
  printf '✓ borders is running\n'
else
  printf '✗ borders is not running\n'
  failures=$((failures + 1))
fi

printf '\nRuntime\n'
if [[ $(yabai -m config layout 2>/dev/null) == "bsp" ]]; then
  printf '✓ BSP tiling is active\n'
else
  printf '✗ BSP tiling is not active\n'
  failures=$((failures + 1))
fi

if [[ $(yabai -m config focus_follows_mouse 2>/dev/null) == "autofocus" ]]; then
  printf '✓ hover focus is active\n'
else
  printf '✗ hover focus is not active\n'
  failures=$((failures + 1))
fi

if yabai -m signal --list 2>/dev/null | jq -e '.[] | select(.label == "kosmos_restore_hover")' >/dev/null; then
  printf '✓ hover-focus recovery is registered\n'
else
  printf '✗ hover-focus recovery is missing\n'
  failures=$((failures + 1))
fi

if [[ $(defaults read com.apple.dock mru-spaces 2>/dev/null) == "0" ]]; then
  printf '✓ automatic Space reordering is disabled\n'
else
  printf '✗ automatic Space reordering is enabled\n'
  failures=$((failures + 1))
fi

if [[ $(defaults read com.apple.dock workspaces-auto-swoosh 2>/dev/null) == "0" ]]; then
  printf '✓ app activation stays on the current Space\n'
else
  printf '✗ app activation may switch to a Space with existing windows\n'
  failures=$((failures + 1))
fi

if [[ $(defaults read com.apple.WindowManager EnableStandardClickToShowDesktop 2>/dev/null) == "0" ]]; then
  printf '✓ wallpaper clicks will not disrupt Space focus\n'
else
  printf '! set “Click wallpaper to reveal desktop” to “Only in Stage Manager”\n'
  warnings=$((warnings + 1))
fi

if [[ $(defaults read com.apple.finder CreateDesktop 2>/dev/null) == "0" ]]; then
  printf '! desktop icons are hidden; focusing a completely empty Space may be less reliable\n'
  warnings=$((warnings + 1))
fi

expected_capture_dir="$HOME/Pictures/Kosmos Captures"
if [[ $(defaults read com.apple.screencapture location 2>/dev/null) == "$expected_capture_dir" ]]; then
  printf '✓ macOS screenshots save to the visible Kósmos Captures folder\n'
else
  printf '✗ macOS screenshots may be hidden on the Desktop\n'
  failures=$((failures + 1))
fi

printf '\nPackage manifest\n'
if HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file "$ROOT_DIR/Brewfile" >/dev/null 2>&1; then
  printf '✓ Brewfile dependencies are satisfied\n'
else
  printf '✗ Brewfile dependencies need installation or updates\n'
  failures=$((failures + 1))
fi

printf '\n'
if (( failures == 0 )); then
  printf 'Kósmos is healthy with %d warning(s).\n' "$warnings"
else
  printf '%d check(s) need attention. See docs/troubleshooting.md.\n' "$failures"
fi
exit "$failures"
