#!/bin/bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

git -C "$ROOT_DIR" pull --ff-only
brew bundle --file "$ROOT_DIR/Brewfile"
brew upgrade
yabai --restart-service
skhd --restart-service
brew services restart sketchybar
sleep 1
launchctl kickstart -k "gui/$(id -u)/homebrew.mxcl.sketchybar" 2>/dev/null || true
printf 'Kósmos is up to date.\n'
