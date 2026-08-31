#!/bin/bash
set -euo pipefail

CAPTURE_DIR="$HOME/Pictures/Kosmos Captures"

notify() {
  osascript -e "display notification \"$2\" with title \"$1\"" 2>/dev/null || true
}

usage() {
  printf 'Usage: kosmos capture screenshot [region|fullscreen] [copy|save] | text | qr | color\n'
}

capture_screenshot() {
  local selection=${1:-region} destination=${2:-copy}
  local timestamp output_file
  timestamp=$(date +%Y-%m-%d_%H-%M-%S)
  mkdir -p "$CAPTURE_DIR"
  output_file="$CAPTURE_DIR/screenshot-$timestamp.png"

  case "$selection:$destination" in
    region:copy) screencapture -i -c ;;
    region:save) screencapture -i "$output_file" ;;
    fullscreen:copy) screencapture -C -c ;;
    fullscreen:save) screencapture -C "$output_file" ;;
    *) usage >&2; exit 2 ;;
  esac

  if [[ "$destination" == "save" && -s "$output_file" ]]; then
    notify "Kósmos Capture" "Saved $(basename "$output_file")"
    printf '%s\n' "$output_file"
  fi
}

capture_region_file() {
  local output_file=$1
  screencapture -i "$output_file"
  [[ -s "$output_file" ]]
}

capture_text() {
  command -v tesseract >/dev/null 2>&1 || { printf 'Install tesseract first.\n' >&2; exit 1; }
  local temporary_dir image_file text
  temporary_dir=$(mktemp -d /private/tmp/kosmos-ocr.XXXXXX)
  trap 'rm -rf "$temporary_dir"' EXIT
  image_file="$temporary_dir/region.png"
  capture_region_file "$image_file" || exit 0
  text=$(tesseract "$image_file" stdout -l eng 2>/dev/null)
  [[ -n "$text" ]] || { notify "Kósmos OCR" "No text found"; exit 1; }
  printf '%s' "$text" | pbcopy
  notify "Kósmos OCR" "Text copied to the clipboard"
  printf '%s\n' "$text"
}

capture_qr() {
  command -v zbarimg >/dev/null 2>&1 || { printf 'Install zbar first.\n' >&2; exit 1; }
  local temporary_dir image_file decoded
  temporary_dir=$(mktemp -d /private/tmp/kosmos-qr.XXXXXX)
  trap 'rm -rf "$temporary_dir"' EXIT
  image_file="$temporary_dir/region.png"
  capture_region_file "$image_file" || exit 0
  decoded=$(zbarimg --quiet --raw "$image_file" 2>/dev/null | head -1)
  [[ -n "$decoded" ]] || { notify "Kósmos QR" "No QR code found"; exit 1; }
  printf '%s' "$decoded" | pbcopy
  notify "Kósmos QR" "Decoded value copied to the clipboard"
}

capture_color() {
  local values red green blue hex
  values=$(osascript -e 'choose color default color {0, 0, 0}' 2>/dev/null) || exit 0
  IFS=',' read -r red green blue <<< "$values"
  hex=$(awk -v r="$red" -v g="$green" -v b="$blue" 'BEGIN { printf "#%02X%02X%02X", r/257, g/257, b/257 }')
  printf '%s' "$hex" | pbcopy
  notify "Kósmos Color" "$hex copied to the clipboard"
  printf '%s\n' "$hex"
}

subcommand=${1:-screenshot}
shift || true
case "$subcommand" in
  screenshot) capture_screenshot "$@" ;;
  text) capture_text ;;
  qr) capture_qr ;;
  color) capture_color ;;
  *) usage >&2; exit 2 ;;
esac
