#!/bin/bash

cores=$(sysctl -n hw.logicalcpu 2>/dev/null || printf '1')
usage=$(ps -A -o %cpu= 2>/dev/null | awk -v cores="$cores" '
  { sum += $1 }
  END {
    value = int(sum / cores + 0.5)
    if (value > 100) value = 100
    printf "%d", value
  }
')

sketchybar --set "$NAME" label="${usage:---}%"
