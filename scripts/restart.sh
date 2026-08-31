#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

printf 'Restarting Kósmos services…\n'
yabai --restart-service
skhd --restart-service
brew services restart sketchybar
brew services restart borders
sleep 2
launchctl kickstart -k "gui/$(id -u)/homebrew.mxcl.sketchybar" 2>/dev/null || true
launchctl kickstart -k "gui/$(id -u)/homebrew.mxcl.borders" 2>/dev/null || true
yabai -m config focus_follows_mouse autofocus

exec "$ROOT_DIR/scripts/doctor.sh"
