#!/bin/bash
if [ -n "$INFO" ]; then
  sketchybar --set "$NAME" label="$INFO"
else
  app=$(yabai -m query --windows --window 2>/dev/null | /usr/bin/jq -r '.app // "Desktop"')
  sketchybar --set "$NAME" label="$app"
fi
