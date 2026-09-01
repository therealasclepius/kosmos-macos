# Kósmos Command Center

The `kosmos` command is the single entry point for managing the environment. Raycast exposes the most useful commands graphically; search for “Kósmos” after installation.

## System

| Command | Purpose |
|---|---|
| `kosmos status` | Show the active theme, desktop, layout, hover focus, battery, and repository version |
| `kosmos doctor` | Run a complete dependency, configuration, service, and runtime check |
| `kosmos test` | Run non-destructive syntax and application smoke tests |
| `kosmos test --live` | Run smoke tests followed by the complete live doctor |
| `kosmos restart` | Restart the selected window manager and SketchyBar, then run the doctor |
| `kosmos update` | Snapshot, fast-forward update, install dependencies, migrate, and restart |
| `kosmos shortcuts` | Open the complete keyboard reference |
| `kosmos wm status` | Show the configured and running window-manager stack |
| `kosmos wm omniwm` | Snapshot, stop yabai/skhd/borders, and enter OmniWM test mode |
| `kosmos wm yabai` | Stop OmniWM and restore the complete yabai stack |
| `kosmos wm restart` | Restart only the currently selected window-manager stack |

Raycast also exposes these actions as **Switch Kósmos Window Manager**.

## Themes

| Command | Purpose |
|---|---|
| `kosmos theme list` | List installed themes |
| `kosmos theme current` | Print the active theme |
| `kosmos theme set osaka-jade` | Apply Osaka Jade everywhere |
| `kosmos theme set kosmos` | Apply the original Kósmos Macchiato look |

Existing Ghostty windows may need `Command + Shift + ,` or a relaunch. Existing Neovim sessions need a restart.

## Capture and utility tools

| Command | Purpose |
|---|---|
| `kosmos capture screenshot region copy` | Select an area and copy it |
| `kosmos capture screenshot region save` | Save a selected area under `~/Pictures/Kosmos Captures` |
| `kosmos capture screenshot fullscreen copy` | Copy the current display |
| `kosmos capture text` | Select an area, recognize its text, and copy it |
| `kosmos capture qr` | Select a QR code and copy its value |
| `kosmos capture color` | Pick a screen color and copy its hex value |
| `kosmos transcode video.mov 1080p` | Create a web-friendly MP4 and copy it as a file |
| `kosmos transcode video.mov 720p` | Create a smaller MP4 |
| `kosmos transcode video.mov gif` | Create a 12 FPS GIF |
| `kosmos notice datetime` | Show date and time |
| `kosmos notice battery` | Show battery state |
| `kosmos notice weather "New York"` | Show a compact weather report |
| `kosmos reminder add 45m "Call Alex"` | Add a reminder to the default Reminders list |
| `kosmos reminder list` | List incomplete reminders made by Kósmos |
| `kosmos reminder clear --yes` | Remove incomplete reminders made by Kósmos |

Screen capture commands may prompt for Raycast or terminal Screen Recording permission. Reminders may prompt for Automation access on first use.

## Development layouts

| Command | Purpose |
|---|---|
| `kosmos dev layout [agent] [second-agent]` | Open an editor, shell, and one or two coding-agent panes |
| `kosmos dev square` | Open a balanced four-pane workspace |
| `kosmos dev multi [agent]` | Create a dev window for every immediate child directory |
| `kosmos dev swarm COUNT COMMAND...` | Tile up to twelve panes running one command |

Agent aliases are `c`/`codex`, `cx`/`claude`, and `oc`/`opencode`. Shell aliases `tdl`, `tds`, `tdlm`, and `tsl` map to the four layouts.

## Recovery

Snapshots live in `~/.local/state/kosmos/snapshots`. Installer backups live in `~/.local/state/kosmos/backups` and are never automatically deleted.

Restoring a snapshot intentionally overwrites the listed managed paths and therefore requires the explicit `--yes` flag. A `pre-restore` snapshot is created first.
