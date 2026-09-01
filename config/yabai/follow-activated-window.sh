#!/bin/bash
set -euo pipefail

process_id=${1:-}
[[ "$process_id" =~ ^[0-9]+$ ]] || exit 0

window=$(
  yabai -m query --windows 2>/dev/null | jq -r --argjson pid "$process_id" '
    [.[] | select(
      .pid == $pid and
      .subrole == "AXStandardWindow" and
      .["is-minimized"] == false and
      .["is-hidden"] == false
    )]
    | if length == 0 then empty
      else ((map(select(.["has-focus"] == true)) + .) | first | "\(.id) \(.space)")
      end
  '
)

[[ -n "$window" ]] || exit 0
read -r window_id target_space <<< "$window"
current_space=$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index')

if [[ "$target_space" != "$current_space" ]]; then
  yabai -m space --focus "$target_space" 2>/dev/null || exit 0
fi

yabai -m window --focus "$window_id" 2>/dev/null || true
