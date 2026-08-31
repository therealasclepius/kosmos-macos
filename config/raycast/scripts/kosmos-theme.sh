#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Change Kósmos Theme
# @raycast.mode compact
# @raycast.packageName Kósmos
# @raycast.icon 🎨
# @raycast.description Apply a complete Kósmos theme.
# @raycast.argument1 { "type": "dropdown", "placeholder": "Theme", "data": [{ "title": "Osaka Jade", "value": "osaka-jade" }, { "title": "Kósmos", "value": "kosmos" }] }

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
kosmos theme set "$1"
