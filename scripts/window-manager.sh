#!/bin/bash
set -euo pipefail

ROOT_DIR=${KOSMOS_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
STATE_DIR="$HOME/.config/kosmos"
MODE_FILE="$STATE_DIR/window-manager"

usage() {
  printf 'Usage: kosmos wm yashiki | omniwm | yabai | status | restart\n'
}

configured_mode() {
  local mode
  mode=$(cat "$MODE_FILE" 2>/dev/null || printf 'yabai')
  case "$mode" in
    yashiki | omniwm | yabai) printf '%s\n' "$mode" ;;
    *) printf 'yabai\n' ;;
  esac
}

record_mode() {
  local mode=$1 temporary
  mkdir -p "$STATE_DIR"
  temporary=$(mktemp "$STATE_DIR/window-manager.XXXXXX")
  printf '%s\n' "$mode" > "$temporary"
  mv "$temporary" "$MODE_FILE"
}

wait_for_process() {
  local process=$1 expected=$2 attempt
  for attempt in {1..30}; do
    if [[ "$expected" == running ]] && pgrep -x "$process" >/dev/null 2>&1; then return 0; fi
    if [[ "$expected" == stopped ]] && ! pgrep -x "$process" >/dev/null 2>&1; then return 0; fi
    sleep 0.2
  done
  return 1
}

restart_bar() {
  brew services restart sketchybar >/dev/null
  sleep 1
  launchctl kickstart -k "gui/$(id -u)/homebrew.mxcl.sketchybar" 2>/dev/null || true
}

stop_yabai_stack() {
  yabai --stop-service 2>/dev/null || true
  skhd --stop-service 2>/dev/null || true
  brew services stop borders >/dev/null 2>&1 || true
  pkill -TERM -x borders 2>/dev/null || true
  wait_for_process yabai stopped || true
  wait_for_process skhd stopped || true
  if ! wait_for_process borders stopped; then
    pkill -KILL -x borders 2>/dev/null || true
    wait_for_process borders stopped || true
  fi
  if pgrep -x yabai >/dev/null 2>&1 || pgrep -x skhd >/dev/null 2>&1 || pgrep -x borders >/dev/null 2>&1; then
    printf 'The yabai stack did not stop cleanly.\n' >&2
    return 1
  fi
}

stop_omniwm() {
  local application_job
  if ! pgrep -x OmniWM >/dev/null 2>&1; then return 0; fi
  osascript -e 'tell application id "com.barut.OmniWM" to quit' >/dev/null 2>&1 || true
  if ! wait_for_process OmniWM stopped; then
    application_job=$(launchctl print "gui/$(id -u)" 2>/dev/null | awk '$3 ~ /^application\.com\.barut\.OmniWM\./ { print $3; exit }')
    if [[ -n "$application_job" ]]; then
      launchctl bootout "gui/$(id -u)/$application_job" 2>/dev/null || true
    fi
    pkill -TERM -x OmniWM 2>/dev/null || true
    if ! wait_for_process OmniWM stopped; then
      pkill -KILL -x OmniWM 2>/dev/null || true
      wait_for_process OmniWM stopped
    fi
  fi
}

stop_yashiki() {
  if ! pgrep -x yashiki >/dev/null 2>&1; then return 0; fi
  if [[ -S /tmp/yashiki.sock ]]; then
    /opt/homebrew/bin/yashiki quit >/dev/null 2>&1 || true
  fi
  osascript -e 'tell application id "dev.typester.yashiki" to quit' >/dev/null 2>&1 || true
  if ! wait_for_process yashiki stopped; then
    pkill -TERM -x yashiki 2>/dev/null || true
    if ! wait_for_process yashiki stopped; then
      pkill -KILL -x yashiki 2>/dev/null || true
      wait_for_process yashiki stopped
    fi
  fi
  pkill -f 'yashiki_bridge.sh' 2>/dev/null || true
}

start_yabai_stack() {
  defaults write com.apple.dock workspaces-auto-swoosh -bool true
  yabai --start-service 2>/dev/null || true
  skhd --start-service 2>/dev/null || true
  brew services start borders >/dev/null 2>&1 || true
  wait_for_process yabai running || launchctl kickstart -k "gui/$(id -u)/com.asmvik.yabai"
  wait_for_process skhd running || launchctl kickstart -k "gui/$(id -u)/com.koekeishiya.skhd"
  wait_for_process borders running || launchctl kickstart -k "gui/$(id -u)/homebrew.mxcl.borders"
  wait_for_process yabai running
  wait_for_process skhd running
  wait_for_process borders running
  yabai -m config focus_follows_mouse autofocus 2>/dev/null || true
}

start_omniwm() {
  [[ -d /Applications/OmniWM.app ]] || {
    printf 'OmniWM is not installed. Run: brew install --cask BarutSRB/tap/omniwm\n' >&2
    return 1
  }
  if [[ $(defaults read com.apple.spaces spans-displays 2>/dev/null || printf '0') == 1 ]]; then
    printf 'OmniWM requires “Displays have separate Spaces” to be enabled, followed by a logout.\n' >&2
    return 1
  fi
  open -a OmniWM
  wait_for_process OmniWM running
}

start_yashiki() {
  local attempt
  [[ -d /Applications/Yashiki.app ]] || {
    printf 'Yashiki is not installed. See docs/troubleshooting.md for the guarded installation steps.\n' >&2
    return 1
  }
  open -a Yashiki >/dev/null 2>&1 || return 1
  for attempt in {1..30}; do
    if pgrep -x yashiki >/dev/null 2>&1 && [[ -S /tmp/yashiki.sock ]]; then
      return 0
    fi
    sleep 0.2
  done
  return 1
}

show_status() {
  local mode conflicts=0
  mode=$(configured_mode)
  printf 'Configured window manager: %s\n' "$mode"
  printf 'Yashiki: %s\n' "$(pgrep -x yashiki >/dev/null 2>&1 && printf running || printf stopped)"
  printf 'OmniWM: %s\n' "$(pgrep -x OmniWM >/dev/null 2>&1 && printf running || printf stopped)"
  printf 'yabai:  %s\n' "$(pgrep -x yabai >/dev/null 2>&1 && printf running || printf stopped)"
  printf 'skhd:   %s\n' "$(pgrep -x skhd >/dev/null 2>&1 && printf running || printf stopped)"
  printf 'borders:%s\n' "$(pgrep -x borders >/dev/null 2>&1 && printf ' running' || printf ' stopped')"
  if [[ "$mode" == yashiki ]]; then
    if ! pgrep -x yashiki >/dev/null 2>&1 || pgrep -x OmniWM >/dev/null 2>&1 || pgrep -x yabai >/dev/null 2>&1 || pgrep -x skhd >/dev/null 2>&1; then
      printf 'Mismatch: Yashiki mode is incomplete or conflicted. Run `kosmos wm restart`.\n' >&2
      conflicts=1
    fi
  elif [[ "$mode" == omniwm ]]; then
    if ! pgrep -x OmniWM >/dev/null 2>&1 || pgrep -x yashiki >/dev/null 2>&1 || pgrep -x yabai >/dev/null 2>&1 || pgrep -x skhd >/dev/null 2>&1 || pgrep -x borders >/dev/null 2>&1; then
      printf 'Mismatch: OmniWM mode is not isolated. Run `kosmos wm restart`.\n' >&2
      conflicts=1
    fi
  elif ! pgrep -x yabai >/dev/null 2>&1 || ! pgrep -x skhd >/dev/null 2>&1 || ! pgrep -x borders >/dev/null 2>&1 || pgrep -x OmniWM >/dev/null 2>&1 || pgrep -x yashiki >/dev/null 2>&1; then
    printf 'Mismatch: yabai mode is incomplete or conflicted. Run `kosmos wm restart`.\n' >&2
    conflicts=1
  fi
  return "$conflicts"
}

switch_to_omniwm() {
  local previous snapshot
  previous=$(configured_mode)
  if [[ "$previous" != omniwm ]]; then
    snapshot=$(KOSMOS_ROOT="$ROOT_DIR" "$ROOT_DIR/scripts/snapshot.sh" create pre-omniwm)
    printf 'Created snapshot: %s\n' "$snapshot"
  fi

  # OmniWM manages its own workspaces and only tiles the active native Space.
  stop_yashiki
  yabai -m space --focus 1 2>/dev/null || true
  if ! stop_yabai_stack; then
    printf 'Could not isolate OmniWM; restoring the yabai stack.\n' >&2
    start_yabai_stack
    return 1
  fi
  record_mode omniwm
  if ! start_omniwm; then
    printf 'OmniWM failed to start; restoring yabai.\n' >&2
    stop_omniwm || true
    record_mode yabai
    start_yabai_stack
    restart_bar
    return 1
  fi
  restart_bar
  printf 'OmniWM test mode is active. Grant Accessibility and Input Monitoring if prompted.\n'
}

switch_to_yashiki() {
  local previous snapshot
  previous=$(configured_mode)
  if [[ "$previous" != yashiki ]]; then
    snapshot=$(KOSMOS_ROOT="$ROOT_DIR" "$ROOT_DIR/scripts/snapshot.sh" create pre-yashiki)
    printf 'Created snapshot: %s\n' "$snapshot"
  fi

  stop_omniwm
  stop_yashiki
  yabai -m space --focus 1 2>/dev/null || true
  if ! stop_yabai_stack; then
    printf 'Could not isolate Yashiki; restoring the yabai stack.\n' >&2
    start_yabai_stack
    return 1
  fi
  record_mode yashiki
  # Load tag items before Yashiki starts its one-shot subscription snapshot.
  restart_bar
  if ! start_yashiki; then
    printf 'Yashiki could not start; restoring yabai. Approve the unsigned app in Privacy & Security, then retry.\n' >&2
    stop_yashiki || true
    record_mode yabai
    start_yabai_stack
    restart_bar
    open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension' >/dev/null 2>&1 || true
    return 1
  fi
  printf 'Yashiki test mode is active. Grant Accessibility if prompted.\n'
}

switch_to_yabai() {
  stop_yashiki
  stop_omniwm
  # Normalize both a Yashiki-tracked borders process and an existing yabai
  # service stack before bringing the stable stack back up.
  stop_yabai_stack
  record_mode yabai
  start_yabai_stack
  restart_bar
  printf 'yabai test mode is active.\n'
}

restart_current() {
  local mode
  mode=$(configured_mode)
  record_mode "$mode"
  case "$mode" in
    omniwm)
      stop_yashiki
      stop_yabai_stack
      stop_omniwm
      start_omniwm
      restart_bar
      ;;
    yashiki)
      stop_omniwm
      stop_yabai_stack
      stop_yashiki
      restart_bar
      start_yashiki
      ;;
    yabai)
      stop_yashiki
      stop_omniwm
      stop_yabai_stack
      start_yabai_stack
      restart_bar
      ;;
  esac
}

subcommand=${1:-status}
case "$subcommand" in
  yashiki) switch_to_yashiki ;;
  omniwm) switch_to_omniwm ;;
  yabai) switch_to_yabai ;;
  status) show_status ;;
  restart) restart_current ;;
  *) usage >&2; exit 2 ;;
esac
