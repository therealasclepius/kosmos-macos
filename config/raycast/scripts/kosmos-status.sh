#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Kósmos Status
# @raycast.mode fullOutput
# @raycast.packageName Kósmos
# @raycast.icon 🪐
# @raycast.description Show the health and current state of Kósmos.

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
exec kosmos status
