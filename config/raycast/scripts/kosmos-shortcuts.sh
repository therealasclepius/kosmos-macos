#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Kósmos Shortcuts
# @raycast.mode fullOutput
# @raycast.packageName Kósmos
# @raycast.icon ⌨️
# @raycast.description Search and review all Kósmos keyboard shortcuts.

SCRIPT_SOURCE=${BASH_SOURCE[0]}
while [[ -L "$SCRIPT_SOURCE" ]]; do
  SCRIPT_DIRECTORY=$(cd -P "$(dirname "$SCRIPT_SOURCE")" && pwd)
  SCRIPT_SOURCE=$(readlink "$SCRIPT_SOURCE")
  [[ "$SCRIPT_SOURCE" != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIRECTORY/$SCRIPT_SOURCE"
done
ROOT_DIR=$(cd -P "$(dirname "$SCRIPT_SOURCE")/../../.." && pwd)
sed -e 's/^#\+ *//' -e 's/`//g' "$ROOT_DIR/docs/shortcuts.md"
