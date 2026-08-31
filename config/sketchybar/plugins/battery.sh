#!/bin/bash
percent=$(pmset -g batt | /usr/bin/grep -Eo '[0-9]+%' | /usr/bin/head -1)
state=$(pmset -g batt | /usr/bin/grep -Eo 'charging|charged|discharging' | /usr/bin/head -1)
case "$state" in
  charging|charged) color=0xff63b07a ;;
  *) color=0xffc1c497 ;;
esac
sketchybar --set "$NAME" label="${percent:-AC}" icon.color="$color"
