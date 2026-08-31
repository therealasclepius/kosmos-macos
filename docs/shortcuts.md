# Kósmos shortcuts

`Option` is the primary window-control modifier. This avoids taking over macOS's familiar `Command` shortcuts.

## Windows

| Shortcut | Action |
|---|---|
| `Option + H/J/K/L` | Focus the window left/down/up/right |
| `Shift + Option + H/J/K/L` | Move the window left/down/up/right |
| `Control + Option + H/J/K/L` | Resize the focused window |
| `Option + F` | Toggle desktop-filling maximize |
| `Shift + Option + Space` | Toggle centered floating mode |
| `Option + B` | Balance all tiled windows |
| `Option + R` | Rotate the BSP layout |

## Desktops and layouts

| Shortcut | Action |
|---|---|
| `Control + 1–9` | Focus Desktop 1–9 |
| `Shift + Option + 1–9` | Send the focused window to Desktop 1–9 |
| `Control + Option + B` | BSP layout |
| `Control + Option + S` | Stack layout |
| `Control + Option + F` | Floating layout |
| `Control + Option + R` | Restart yabai |

Create the desired desktops once in Mission Control. macOS restricts automatic desktop creation without unsupported system modifications.

## Applications

| Shortcut | Action |
|---|---|
| `Option + Return` | Open Ghostty |
| `Shift + Option + Return` | Open or attach to the `main` tmux session |
| `Shift + Option + V` | Open Neovim in Ghostty |
| `Shift + Option + Y` | Open Yazi in Ghostty |
| `Shift + Option + E` | Finder |
| `Shift + Option + M` | Messages |
| `Shift + Option + N` | Notes |
| `Shift + Option + I` | Mail |

## tmux

The prefix is `Control + Space`.

| Keys after prefix | Action |
|---|---|
| `|` | Split horizontally |
| `-` | Split vertically |
| `H/J/K/L` | Move between panes |
| `Shift + H/J/K/L` | Resize panes |
| `R` | Reload the tmux configuration |

## Terminal workflow

| Command | Action |
|---|---|
| `y` | Open Yazi and leave the shell in the directory selected on exit |
| `t` | Open or attach to the persistent `main` tmux session |
| `tdl [agent]` | Create the standard editor/agent/shell dev layout |
| `tds` | Create a balanced four-pane dev layout |
| `tdlm [agent]` | Create one dev window for each child directory |
| `tsl COUNT COMMAND` | Create a tiled command swarm |
| `lg` | Open Lazygit |
| `ga BRANCH` | Create a Git worktree beside the repository and enter it |
| `ll` | Detailed Git-aware file listing |
| `preview FILE` | Preview a file with Bat |

## Raycast commands

Open Raycast and search for “Kósmos” to find Status, Restart, Change Theme, Shortcuts, Copy Text from Screen, Scan QR from Screen, Pick Screen Color, and Quick Reminder.

## Neovim and Yazi

In Neovim, press `Space` to reveal LazyVim commands. In Yazi, use `H/J/K/L` to navigate and `~` to display its shortcuts.
