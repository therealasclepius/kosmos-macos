#!/bin/bash
set -euo pipefail

wallpaper_file=${1:?Usage: set-wallpaper.sh /absolute/path/to/wallpaper}

if [[ ! -f "$wallpaper_file" ]]; then
  printf 'Wallpaper not found: %s\n' "$wallpaper_file" >&2
  exit 1
fi

focused_space=$(yabai -m query --spaces --space | jq -r '.index')

restore_space() {
  if ! yabai -m query --spaces >/dev/null 2>&1; then
    yabai --restart-service
    sleep 3
  fi
  yabai -m space --focus "$focused_space" 2>/dev/null || true
  sleep 1

  if ! yabai -m query --spaces >/dev/null 2>&1; then
    yabai --restart-service
    sleep 3
  fi
}
trap restore_space EXIT

while IFS= read -r space_index; do
  if [[ "$space_index" != "$focused_space" ]]; then
    yabai -m space --focus "$space_index"
    sleep 1
  fi

  osascript -e 'on run argv' \
    -e 'tell application "System Events" to tell every desktop to set picture to POSIX file (item 1 of argv)' \
    -e 'end run' "$wallpaper_file"
done < <(yabai -m query --spaces | jq -r '.[].index')
