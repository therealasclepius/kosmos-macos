#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Quick Reminder
# @raycast.mode compact
# @raycast.packageName Kósmos
# @raycast.icon ⏰
# @raycast.description Create a reminder using a duration such as 20m, 2h, or 1d.
# @raycast.argument1 { "type": "text", "placeholder": "When (20m, 2h, 1d)" }
# @raycast.argument2 { "type": "text", "placeholder": "Reminder" }

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
kosmos reminder add "$1" "$2"
