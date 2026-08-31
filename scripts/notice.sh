#!/bin/bash
set -euo pipefail

notify() {
  osascript - "$1" "$2" <<'APPLESCRIPT' 2>/dev/null || true
on run argv
  display notification (item 2 of argv) with title (item 1 of argv)
end run
APPLESCRIPT
  printf '%s: %s\n' "$1" "$2"
}

subcommand=${1:-datetime}
shift || true
case "$subcommand" in
  datetime)
    notify "Date & Time" "$(date '+%A, %B %-d · %-I:%M %p')"
    ;;
  battery)
    battery_line=$(pmset -g batt | tail -1 | sed 's/^[[:space:]]*//')
    notify "Battery" "$battery_line"
    ;;
  weather)
    location=${*:-}
    encoded_location=${location// /+}
    weather=$(curl -fsSL --max-time 10 "https://wttr.in/${encoded_location}?format=%l:+%c+%t,+feels+like+%f,+%w" 2>/dev/null) || {
      printf 'Weather lookup failed.\n' >&2
      exit 1
    }
    notify "Weather" "$weather"
    ;;
  *) printf 'Usage: kosmos notice datetime | battery | weather [location]\n' >&2; exit 2 ;;
esac
