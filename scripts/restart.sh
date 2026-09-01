#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

printf 'Restarting Kósmos services…\n'
"$ROOT_DIR/scripts/window-manager.sh" restart

exec "$ROOT_DIR/scripts/doctor.sh"
