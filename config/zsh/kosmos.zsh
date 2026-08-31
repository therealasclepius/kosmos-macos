# Kósmos shell workflow
if [[ -n "${KOSMOS_SHELL_LOADED:-}" ]]; then
  return
fi
export KOSMOS_SHELL_LOADED=1
export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-nvim}

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

function y() {
  local temporary_file selected_directory
  temporary_file="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$temporary_file"
  selected_directory="$(command cat -- "$temporary_file")"
  if [[ -n "$selected_directory" && "$selected_directory" != "$PWD" ]]; then
    builtin cd -- "$selected_directory"
  fi
  rm -f -- "$temporary_file"
}

function compress() {
  [[ $# -eq 1 ]] || { printf 'Usage: compress <file-or-directory>\n' >&2; return 2; }
  tar -czf "${1%/}.tar.gz" "${1%/}"
}

function decompress() {
  [[ $# -eq 1 ]] || { printf 'Usage: decompress <archive.tar.gz>\n' >&2; return 2; }
  tar -xzf "$1"
}

function tdl() { kosmos dev layout "$@"; }
function tds() { kosmos dev square "$@"; }
function tdlm() { kosmos dev multi "$@"; }
function tsl() { kosmos dev swarm "$@"; }

function ga() {
  local branch=${1:-}
  [[ -n "$branch" ]] || { printf 'Usage: ga <branch>\n' >&2; return 2; }
  local repository_root destination
  repository_root=$(git rev-parse --show-toplevel) || return
  destination="$(dirname "$repository_root")/$(basename "$repository_root")-$branch"
  git worktree add -b "$branch" "$destination" && cd "$destination"
}

alias l='eza --icons=auto --group-directories-first'
alias ll='eza -lah --icons=auto --group-directories-first --git'
alias tree='eza --tree --icons=auto --group-directories-first'
alias preview='bat --paging=always --style=numbers,changes,header'
alias t='tmux new-session -A -s main'
alias ta='tmux attach-session -t main'
alias lg='lazygit'
alias ic='tdl codex'
alias ix='tdl claude'

export STARSHIP_CONFIG="$HOME/.config/kosmos/starship.toml"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
