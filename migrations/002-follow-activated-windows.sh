#!/bin/bash
set -euo pipefail

defaults write com.apple.dock workspaces-auto-swoosh -bool true

target="$HOME/.config/yabai/follow-activated-window.sh"
mkdir -p "$(dirname "$target")"
if [[ ! -e "$target" && ! -L "$target" ]]; then
  ln -s "$KOSMOS_ROOT/config/yabai/follow-activated-window.sh" "$target"
fi

killall Dock 2>/dev/null || true
