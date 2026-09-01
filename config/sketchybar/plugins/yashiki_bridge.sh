#!/bin/bash

# Adapted from Yashiki's MIT-licensed SketchyBar example. It translates the
# daemon's JSON event stream into one compact custom SketchyBar event.
set -u

command -v jq >/dev/null 2>&1 || exit 1
command -v yashiki >/dev/null 2>&1 || exit 1

state='{"displays":{},"windows":{},"focused":""}'

trigger_bar() {
  local active occupied=0 tags
  active=$(jq -r '.displays[.focused] // 0' <<<"$state")
  while IFS= read -r tags; do
    [[ -n "$tags" ]] && occupied=$((occupied | tags))
  done < <(jq -r '.windows[]' <<<"$state")
  sketchybar --trigger yashiki_workspace_change ACTIVE_TAGS="$active" OCCUPIED_TAGS="$occupied"
}

process_line() {
  local line=$1 event_type display_id visible_tags window_id window_tags
  event_type=$(jq -r '.type' <<<"$line")
  case "$event_type" in
    snapshot)
      state=$(jq '{
        displays: (.displays | map({(.id | tostring): .visible_tags}) | add // {}),
        windows: (.windows | map({(.id | tostring): .tags}) | add // {}),
        focused: (.focused_display_id | tostring)
      }' <<<"$line")
      ;;
    tags_changed)
      display_id=$(jq -r '.display_id' <<<"$line")
      visible_tags=$(jq -r '.visible_tags' <<<"$line")
      state=$(jq --arg id "$display_id" --argjson tags "$visible_tags" '.displays[$id] = $tags' <<<"$state")
      ;;
    display_focused)
      display_id=$(jq -r '.display_id' <<<"$line")
      state=$(jq --arg id "$display_id" '.focused = $id' <<<"$state")
      ;;
    window_created|window_updated)
      window_id=$(jq -r '.window.id' <<<"$line")
      window_tags=$(jq -r '.window.tags' <<<"$line")
      state=$(jq --arg id "$window_id" --argjson tags "$window_tags" '.windows[$id] = $tags' <<<"$state")
      ;;
    window_destroyed)
      window_id=$(jq -r '.window_id' <<<"$line")
      state=$(jq --arg id "$window_id" 'del(.windows[$id])' <<<"$state")
      ;;
    *) return ;;
  esac
  trigger_bar
}

while true; do
  while IFS= read -r line; do
    [[ -n "$line" ]] && process_line "$line"
  done < <(yashiki subscribe --snapshot --filter tags,focus,window 2>/dev/null)
  sleep 2
done
