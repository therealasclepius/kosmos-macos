#!/bin/bash

volume=$(osascript -e 'return output volume of (get volume settings)' 2>/dev/null)
muted=$(osascript -e 'return output muted of (get volume settings)' 2>/dev/null)

if [[ "$muted" == "true" || "${volume:-0}" -eq 0 ]]; then
  icon="󰝟"
  label="MUTE"
elif (( volume < 35 )); then
  icon="󰕿"
  label="${volume}%"
elif (( volume < 70 )); then
  icon="󰖀"
  label="${volume}%"
else
  icon="󰕾"
  label="${volume}%"
fi

sketchybar --set "$NAME" icon="$icon" label="$label"
