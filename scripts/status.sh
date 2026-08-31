#!/bin/bash
set -u

printf 'Kósmos status\n\n'
printf 'Theme:       %s\n' "$(cat "$HOME/.config/kosmos/theme" 2>/dev/null || printf 'osaka-jade')"
printf 'Desktop:     %s\n' "$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index' 2>/dev/null || printf 'unavailable')"
printf 'Window mode: %s\n' "$(yabai -m config layout 2>/dev/null || printf 'unavailable')"
printf 'Hover focus: %s\n' "$(yabai -m config focus_follows_mouse 2>/dev/null || printf 'unavailable')"
printf 'Battery:     %s\n' "$(pmset -g batt | grep -Eo '[0-9]+%' | head -1)"
printf 'Repository:  %s\n' "$(git -C "${KOSMOS_ROOT:-$HOME/kosmos-macos}" rev-parse --short HEAD 2>/dev/null || printf 'unavailable')"
