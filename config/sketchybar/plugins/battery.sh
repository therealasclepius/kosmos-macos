#!/bin/bash
PALETTE_FILE="$HOME/.config/kosmos/palette.sh"
if [[ -r "$PALETTE_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$PALETTE_FILE"
else
  GREEN=0xff63b07a FOREGROUND=0xffc1c497
fi
percent=$(pmset -g batt | /usr/bin/grep -Eo '[0-9]+%' | /usr/bin/head -1)
state=$(pmset -g batt | /usr/bin/grep -Eo 'charging|charged|discharging' | /usr/bin/head -1)
case "$state" in
  charging|charged) color="$GREEN" ;;
  *) color="$FOREGROUND" ;;
esac
sketchybar --set "$NAME" label="${percent:-AC}" icon.color="$color"
