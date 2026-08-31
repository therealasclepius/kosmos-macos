#!/bin/bash

free=$(memory_pressure 2>/dev/null | awk '
  /System-wide memory free percentage/ {
    gsub(/%/, "", $5)
    print $5
    exit
  }
')

if [[ -n "$free" ]]; then
  used=$((100 - free))
  label="${used}%"
else
  label="--%"
fi

sketchybar --set "$NAME" label="$label"
