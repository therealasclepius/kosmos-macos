#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Scan QR from Screen
# @raycast.mode compact
# @raycast.packageName Kósmos
# @raycast.icon ▣
# @raycast.description Select a QR code and copy its contents.

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
kosmos capture qr
