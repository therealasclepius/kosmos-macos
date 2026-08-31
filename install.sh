#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
STATE_DIR="$HOME/.local/state/kosmos"
BACKUP_DIR="$STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

say() { printf '\033[1;34mKósmos:\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWarning:\033[0m %s\n' "$*"; }
run() {
  if $DRY_RUN; then
    printf '+ '; printf '%q ' "$@"; printf '\n'
  else
    "$@"
  fi
}

if [[ $(uname -s) != "Darwin" ]]; then
  printf 'Kósmos currently supports macOS only.\n' >&2
  exit 1
fi

if [[ $(uname -m) != "arm64" ]]; then
  warn "This release is tested on Apple Silicon; continuing on $(uname -m)."
fi

say "Installing the keyboard-first macOS environment"

if ! command -v brew >/dev/null 2>&1; then
  if $DRY_RUN; then
    say "Would install Homebrew"
  else
    say "Homebrew is required and will be installed now."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi
fi

run brew bundle --file "$ROOT_DIR/Brewfile"

if command -v npm >/dev/null 2>&1; then
  if ! command -v firecrawl >/dev/null 2>&1; then
    run npm install --global firecrawl-cli
  fi
else
  warn "npm is unavailable; Firecrawl CLI was skipped."
fi

run mkdir -p "$BACKUP_DIR" "$STATE_DIR"

install_link() {
  local source=$1 target=$2 relative backup
  relative=${target#"$HOME"/}
  backup="$BACKUP_DIR/$relative"
  run mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]] && [[ $(readlink "$target") == "$source" ]]; then
    say "Already linked: $target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    run mkdir -p "$(dirname "$backup")"
    run mv "$target" "$backup"
    say "Backed up $target"
  fi
  run ln -s "$source" "$target"
}

install_link "$ROOT_DIR/config/yabairc" "$HOME/.yabairc"
install_link "$ROOT_DIR/config/yabairc" "$HOME/.config/yabai/yabairc"
install_link "$ROOT_DIR/config/yabai/toggle-maximize.sh" "$HOME/.config/yabai/toggle-maximize.sh"
install_link "$ROOT_DIR/config/skhdrc" "$HOME/.skhdrc"
install_link "$ROOT_DIR/config/tmux.conf" "$HOME/.tmux.conf"
install_link "$ROOT_DIR/config/sketchybar" "$HOME/.config/sketchybar"
install_link "$ROOT_DIR/config/nvim" "$HOME/.config/nvim"
install_link "$ROOT_DIR/config/yazi" "$HOME/.config/yazi"

if ! $DRY_RUN; then
  printf '%s\n' "$BACKUP_DIR" > "$STATE_DIR/latest-backup"
fi

run chmod +x "$ROOT_DIR/config/yabairc" "$ROOT_DIR/config/sketchybar/sketchybarrc"
run chmod +x "$ROOT_DIR/config/yabai/toggle-maximize.sh"
for plugin in "$ROOT_DIR"/config/sketchybar/plugins/*.sh; do run chmod +x "$plugin"; done

# Reversible macOS preferences.
run defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
run defaults write NSGlobalDomain _HIHideMenuBar -bool true
run defaults write NSGlobalDomain KeyRepeat -int 2
run defaults write NSGlobalDomain InitialKeyRepeat -int 12
run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
run defaults write com.apple.finder AppleShowAllFiles -bool true
run defaults write com.apple.dock mru-spaces -bool false
run defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

if $DRY_RUN; then
  run yabai --start-service
  run skhd --start-service
else
  yabai --start-service 2>/dev/null || yabai --restart-service
  skhd --start-service 2>/dev/null || skhd --restart-service
fi
run brew services restart sketchybar

if ! $DRY_RUN; then
  sleep 1
  launchctl kickstart -k "gui/$(id -u)/homebrew.mxcl.sketchybar" 2>/dev/null || true
  killall Finder 2>/dev/null || true
  killall Dock 2>/dev/null || true
  killall SystemUIServer 2>/dev/null || true
fi

say "Installation complete."
say "Next: run $ROOT_DIR/scripts/permissions.sh, approve macOS access, then run $ROOT_DIR/scripts/doctor.sh"
