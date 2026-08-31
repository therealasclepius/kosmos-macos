#!/bin/bash
if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" icon.color=0xff111c18 background.color=0xff71cead
else
  sketchybar --set "$NAME" icon.color=0xffc1c497 background.color=0x0023372b
fi
