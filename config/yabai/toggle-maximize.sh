#!/bin/bash
set -euo pipefail

window=$(yabai -m query --windows --window)
window_id=$(jq -r '.id' <<<"$window")
is_floating=$(jq -r '."is-floating"' <<<"$window")

if [[ "$is_floating" != "true" ]]; then
  exec yabai -m window --toggle zoom-fullscreen
fi

state_file="${TMPDIR:-/tmp}/kosmos-yabai-maximize-${window_id}"

if [[ -f "$state_file" ]]; then
  IFS=$'\t' read -r x y width height < "$state_file"
  yabai -m window --resize "abs:${width}:${height}"
  yabai -m window --move "abs:${x}:${y}"
  rm -f "$state_file"
else
  jq -r '[.frame.x, .frame.y, .frame.w, .frame.h] | @tsv' <<<"$window" > "$state_file"
  yabai -m window --grid 1:1:0:0:1:1
fi
