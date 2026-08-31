#!/bin/bash
set -euo pipefail

usage() {
  printf 'Usage: kosmos reminder add <10m|2h|1d> <message...> | list | clear [--yes]\n'
}

duration_seconds() {
  local value=$1 number unit
  if [[ "$value" =~ ^([0-9]+)([smhd]?)$ ]]; then
    number=${BASH_REMATCH[1]}
    unit=${BASH_REMATCH[2]:-m}
    case "$unit" in
      s) printf '%d' "$number" ;;
      m) printf '%d' $((number * 60)) ;;
      h) printf '%d' $((number * 3600)) ;;
      d) printf '%d' $((number * 86400)) ;;
    esac
  else
    return 1
  fi
}

subcommand=${1:-list}
shift || true
case "$subcommand" in
  add)
    duration=${1:-}
    shift || true
    [[ -n "$duration" && $# -gt 0 ]] || { usage >&2; exit 2; }
    seconds=$(duration_seconds "$duration") || { printf 'Invalid duration: %s\n' "$duration" >&2; exit 2; }
    message=$*
    osascript - "$seconds" "$message" <<'APPLESCRIPT'
on run argv
  set delaySeconds to (item 1 of argv) as integer
  set reminderName to item 2 of argv
  set dueAt to (current date) + delaySeconds
  tell application "Reminders"
    tell default list
      make new reminder with properties {name:reminderName, body:"Created by Kósmos", due date:dueAt}
    end tell
  end tell
end run
APPLESCRIPT
    printf 'Reminder created for %s from now.\n' "$duration"
    ;;
  list)
    osascript <<'APPLESCRIPT'
tell application "Reminders"
  set output to ""
  repeat with itemReminder in (reminders of default list whose completed is false)
    if body of itemReminder is "Created by Kósmos" then
      set output to output & name of itemReminder & " — " & (due date of itemReminder as text) & linefeed
    end if
  end repeat
  return output
end tell
APPLESCRIPT
    ;;
  clear)
    [[ "${1:-}" == "--yes" ]] || { printf 'Run `kosmos reminder clear --yes` to remove Kósmos reminders.\n' >&2; exit 2; }
    osascript <<'APPLESCRIPT'
tell application "Reminders"
  delete (reminders of default list whose completed is false and body is "Created by Kósmos")
end tell
APPLESCRIPT
    printf 'Cleared incomplete Kósmos reminders.\n'
    ;;
  *) usage >&2; exit 2 ;;
esac
