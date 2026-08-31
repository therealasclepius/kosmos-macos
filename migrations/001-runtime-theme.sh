#!/bin/bash
set -euo pipefail

theme_name=$(cat "$HOME/.config/kosmos/theme" 2>/dev/null || printf 'osaka-jade')
"$KOSMOS_ROOT/scripts/theme.sh" set "$theme_name" --no-wallpaper
