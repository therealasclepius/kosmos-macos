#!/bin/bash
if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" icon.color=0xff24273a background.color=0xff8aadf4
else
  sketchybar --set "$NAME" icon.color=0xffcad3f5 background.color=0x00363a4f
fi
