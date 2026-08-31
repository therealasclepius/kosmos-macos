#!/bin/bash
set -euo pipefail

input_file=${1:-}
preset=${2:-1080p}
[[ -f "$input_file" ]] || { printf 'Usage: kosmos transcode <file> [1080p|720p|gif]\n' >&2; exit 2; }
command -v ffmpeg >/dev/null 2>&1 || { printf 'Install ffmpeg first.\n' >&2; exit 1; }

input_file=$(cd "$(dirname "$input_file")" && pwd)/$(basename "$input_file")
base_name=${input_file%.*}

case "$preset" in
  1080p)
    output_file="$base_name-1080p.mp4"
    scale="scale='min(1920,iw)':-2"
    ffmpeg_args=(-c:v libx264 -crf 23 -preset medium -c:a aac -b:a 160k -movflags +faststart)
    ;;
  720p)
    output_file="$base_name-720p.mp4"
    scale="scale='min(1280,iw)':-2"
    ffmpeg_args=(-c:v libx264 -crf 25 -preset medium -c:a aac -b:a 128k -movflags +faststart)
    ;;
  gif)
    output_file="$base_name-720p.gif"
    scale="fps=12,scale='min(1280,iw)':-2:flags=lanczos"
    ffmpeg_args=(-loop 0)
    ;;
  *) printf 'Unknown preset: %s\n' "$preset" >&2; exit 2 ;;
esac

if [[ -e "$output_file" ]]; then
  output_file="${output_file%.*}-$(date +%H%M%S).${output_file##*.}"
fi

ffmpeg -hide_banner -loglevel error -n -i "$input_file" -vf "$scale" "${ffmpeg_args[@]}" "$output_file"
osascript -e 'on run argv' -e 'set the clipboard to POSIX file (item 1 of argv)' -e 'end run' "$output_file"
osascript -e "display notification \"$(basename "$output_file") copied as a file\" with title \"Kósmos Transcode\"" 2>/dev/null || true
printf '%s\n' "$output_file"
