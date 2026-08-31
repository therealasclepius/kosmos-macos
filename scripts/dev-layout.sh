#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  kosmos dev layout [agent] [second-agent]
  kosmos dev square
  kosmos dev multi [agent] [second-agent]
  kosmos dev swarm <count> <command...>

Agent aliases: c/codex, cx/claude, oc/opencode
EOF
}

outside_session=""
new_window_id=""

resolve_agent() {
  case "${1:-codex}" in
    c | codex) printf 'codex' ;;
    cx | claude) printf 'claude' ;;
    oc | opencode) printf 'opencode' ;;
    *) printf '%s' "$1" ;;
  esac
}

available_command() {
  local requested=$1
  if command -v "${requested%% *}" >/dev/null 2>&1; then
    printf '%s' "$requested"
  else
    printf 'printf "Command not installed: %s\\n"; exec "$SHELL"' "$requested"
  fi
}

new_workspace() {
  local directory=$1 window_name=$2 initial_command=$3
  if [[ -n "${TMUX:-}" ]]; then
    new_window_id=$(tmux new-window -P -F '#{window_id}' -n "$window_name" -c "$directory" "$initial_command")
  else
    if [[ -z "$outside_session" ]]; then
      outside_session="kosmos-$(basename "$PWD" | tr -cs '[:alnum:]' '-')"
      outside_session=${outside_session%-}
      if tmux has-session -t "$outside_session" 2>/dev/null; then
        outside_session="$outside_session-$(date +%H%M%S)"
      fi
      new_window_id=$(tmux new-session -d -P -F '#{window_id}' -s "$outside_session" -n "$window_name" -c "$directory" "$initial_command")
    else
      new_window_id=$(tmux new-window -P -F '#{window_id}' -t "$outside_session" -n "$window_name" -c "$directory" "$initial_command")
    fi
  fi
}

attach_if_needed() {
  if [[ -z "${TMUX:-}" && -n "$outside_session" ]]; then
    if [[ "${KOSMOS_DEV_NO_ATTACH:-false}" == "true" ]]; then
      printf 'Created tmux session: %s\n' "$outside_session"
    else
      exec tmux attach-session -t "$outside_session"
    fi
  fi
}

build_layout() {
  local directory=$1 first_agent=$2 second_agent=${3:-} window_name=${4:-dev}
  local editor=${EDITOR:-nvim} window_id editor_pane agent_pane
  new_workspace "$directory" "$window_name" "$editor"
  window_id=$new_window_id
  editor_pane=$(tmux list-panes -t "$window_id" -F '#{pane_id}' | sed -n '1p')
  agent_pane=$(tmux split-window -h -p 45 -P -F '#{pane_id}' -t "$window_id" -c "$directory" "$first_agent")
  tmux split-window -v -p 32 -t "$agent_pane" -c "$directory"
  if [[ -n "$second_agent" ]]; then
    tmux split-window -v -p 50 -t "$agent_pane" -c "$directory" "$second_agent"
  fi
  tmux select-pane -t "$editor_pane"
}

subcommand=${1:-layout}
shift || true
case "$subcommand" in
  layout)
    first_agent=$(available_command "$(resolve_agent "${1:-codex}")")
    second_agent=""
    [[ -n "${2:-}" ]] && second_agent=$(available_command "$(resolve_agent "$2")")
    build_layout "$PWD" "$first_agent" "$second_agent"
    attach_if_needed
    ;;
  square)
    editor=${EDITOR:-nvim}
    new_workspace "$PWD" square "$editor"
    window_id=$new_window_id
    first_pane=$(tmux list-panes -t "$window_id" -F '#{pane_id}' | sed -n '1p')
    right_pane=$(tmux split-window -h -p 50 -P -F '#{pane_id}' -t "$window_id" -c "$PWD" 'while true; do clear; git diff --stat 2>/dev/null || true; sleep 2; done')
    tmux split-window -v -p 50 -t "$first_pane" -c "$PWD"
    tmux split-window -v -p 50 -t "$right_pane" -c "$PWD" "$(available_command "${KOSMOS_DEV_AGENT:-codex}")"
    tmux select-layout -t "$window_id" tiled
    tmux select-pane -t "$first_pane"
    attach_if_needed
    ;;
  multi)
    first_agent=$(available_command "$(resolve_agent "${1:-codex}")")
    second_agent=""
    [[ -n "${2:-}" ]] && second_agent=$(available_command "$(resolve_agent "$2")")
    found=false
    for child_dir in "$PWD"/*/; do
      [[ -d "$child_dir" ]] || continue
      found=true
      build_layout "${child_dir%/}" "$first_agent" "$second_agent" "$(basename "${child_dir%/}")"
    done
    $found || { printf 'No subdirectories found.\n' >&2; exit 1; }
    attach_if_needed
    ;;
  swarm)
    pane_count=${1:-}
    shift || true
    [[ "$pane_count" =~ ^[1-9][0-9]*$ ]] && (( pane_count <= 12 )) || { printf 'Pane count must be 1-12.\n' >&2; exit 2; }
    [[ $# -gt 0 ]] || { usage >&2; exit 2; }
    printf -v command_string '%q ' "$@"
    new_workspace "$PWD" swarm "$command_string"
    window_id=$new_window_id
    for (( pane_number=1; pane_number<pane_count; pane_number++ )); do
      tmux split-window -t "$window_id" -c "$PWD" "$command_string"
      tmux select-layout -t "$window_id" tiled
    done
    attach_if_needed
    ;;
  *) usage >&2; exit 2 ;;
esac
