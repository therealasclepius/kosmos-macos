#!/bin/bash
set -euo pipefail

SBARLUA_REPOSITORY=https://github.com/FelixKratz/SbarLua.git
SBARLUA_REF=${SBARLUA_REF:-dba9cc421b868c918d5c23c408544a28aadf2f2f}
INSTALL_DIR="$HOME/.local/share/sketchybar_lua"
MODULE_PATH="$INSTALL_DIR/sketchybar.so"
VERSION_PATH="$INSTALL_DIR/.kosmos-version"

for required_command in git make clang; do
  command -v "$required_command" >/dev/null 2>&1 || {
    printf 'SbarLua requires %s. Install the Xcode Command Line Tools first.\n' "$required_command" >&2
    exit 1
  }
done

if [[ -f "$MODULE_PATH" && -f "$VERSION_PATH" && "$(cat "$VERSION_PATH")" == "$SBARLUA_REF" ]]; then
  printf 'SbarLua is already installed at %s\n' "$MODULE_PATH"
  exit 0
fi

source_dir=$(mktemp -d /private/tmp/kosmos-sbarlua.XXXXXX)
cleanup() {
  case "$source_dir" in
    /private/tmp/kosmos-sbarlua.*) find "$source_dir" -depth -delete ;;
  esac
}
trap cleanup EXIT

git -C "$source_dir" init --quiet
git -C "$source_dir" remote add origin "$SBARLUA_REPOSITORY"
git -C "$source_dir" fetch --quiet --depth 1 origin "$SBARLUA_REF"
git -C "$source_dir" checkout --quiet --detach FETCH_HEAD
make -C "$source_dir" install

[[ -f "$MODULE_PATH" ]] || { printf 'SbarLua build did not produce %s\n' "$MODULE_PATH" >&2; exit 1; }
printf '%s\n' "$SBARLUA_REF" > "$VERSION_PATH"
printf 'Installed SbarLua %s\n' "$SBARLUA_REF"
