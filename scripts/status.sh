#!/bin/bash
set -u

printf 'Kósmos status\n\n'
window_manager=$(cat "$HOME/.config/kosmos/window-manager" 2>/dev/null || printf 'yabai')
printf 'Theme:       %s\n' "$(cat "$HOME/.config/kosmos/theme" 2>/dev/null || printf 'osaka-jade')"
printf 'Window mgr:  %s\n' "$window_manager"
if [[ "$window_manager" == yashiki ]]; then
  printf 'Desktop:     Yashiki tags\n'
  printf 'Window mode: %s\n' "$(yashiki layout-get 2>/dev/null || printf 'unavailable')"
  printf 'Hover focus: %s\n' "$(yashiki get-auto-raise 2>/dev/null || printf 'unavailable')"
elif [[ "$window_manager" == omniwm ]]; then
  printf 'Desktop:     OmniWM workspace\n'
  printf 'Window mode: managed by OmniWM\n'
  printf 'Hover focus: managed by OmniWM\n'
else
  printf 'Desktop:     %s\n' "$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index' 2>/dev/null || printf 'unavailable')"
  printf 'Window mode: %s\n' "$(yabai -m config layout 2>/dev/null || printf 'unavailable')"
  printf 'Hover focus: %s\n' "$(yabai -m config focus_follows_mouse 2>/dev/null || printf 'unavailable')"
fi
printf 'Battery:     %s\n' "$(pmset -g batt | grep -Eo '[0-9]+%' | head -1)"
printf 'Repository:  %s\n' "$(git -C "${KOSMOS_ROOT:-$HOME/kosmos-macos}" rev-parse --short HEAD 2>/dev/null || printf 'unavailable')"
