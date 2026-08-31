#!/bin/bash
PALETTE_FILE="$HOME/.config/kosmos/palette.sh"
if [[ -r "$PALETTE_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$PALETTE_FILE"
else
  ACTIVE_TEXT=0xff111c18 ACCENT=0xff71cead FOREGROUND=0xffc1c497 INACTIVE_SURFACE=0x0023372b
fi

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" icon.color="$ACTIVE_TEXT" background.color="$ACCENT"
else
  sketchybar --set "$NAME" icon.color="$FOREGROUND" background.color="$INACTIVE_SURFACE"
fi
