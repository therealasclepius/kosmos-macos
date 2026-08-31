#!/bin/bash
set -u

failures=0
check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    printf '✓ %-14s %s\n' "$1" "$(command -v "$1")"
  else
    printf '✗ %-14s missing\n' "$1"
    failures=$((failures + 1))
  fi
}

printf 'Kósmos system check\n\n'
for command in brew yabai skhd sketchybar tmux nvim yazi lazygit gh delta rg fd jq mise firecrawl; do
  check_command "$command"
done

printf '\nConfiguration\n'
for path in "$HOME/.yabairc" "$HOME/.skhdrc" "$HOME/.tmux.conf" \
  "$HOME/.config/sketchybar" "$HOME/.config/nvim" "$HOME/.config/yazi"; do
  if [[ -e "$path" || -L "$path" ]]; then
    printf '✓ %s\n' "$path"
  else
    printf '✗ %s\n' "$path"
    failures=$((failures + 1))
  fi
done

printf '\nServices\n'
for service in yabai skhd; do
  if pgrep -x "$service" >/dev/null 2>&1; then
    printf '✓ %s is running\n' "$service"
  else
    printf '✗ %s is not running\n' "$service"
    failures=$((failures + 1))
  fi
done

if pgrep -x sketchybar >/dev/null 2>&1; then
  printf '✓ sketchybar is running\n'
else
  printf '✗ sketchybar is not running\n'
  failures=$((failures + 1))
fi

printf '\n'
if (( failures == 0 )); then
  printf 'Kósmos is healthy.\n'
else
  printf '%d check(s) need attention. See docs/troubleshooting.md.\n' "$failures"
fi
exit "$failures"
