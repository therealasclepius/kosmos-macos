#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Switch Kósmos Window Manager
# @raycast.mode compact
# @raycast.packageName Kósmos
# @raycast.icon 🧭
# @raycast.description Safely switch among Yashiki, OmniWM, and the stable yabai stack.
# @raycast.argument1 { "type": "dropdown", "placeholder": "Window manager", "data": [{ "title": "Yashiki Test Mode", "value": "yashiki" }, { "title": "Stable yabai Mode", "value": "yabai" }, { "title": "OmniWM Test Mode", "value": "omniwm" }, { "title": "Show Status", "value": "status" }] }

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
exec kosmos wm "$1"
