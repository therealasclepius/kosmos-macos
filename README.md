# Kósmos

An ordered, keyboard-first macOS environment inspired by the workflow and visual cohesion of Omarchy.

![Osaka Jade wallpaper](assets/osaka-jade-bg.jpg)

Kósmos combines automatic window tiling, fast workspace navigation, a custom status bar, persistent terminal sessions, a polished terminal editor, and modern command-line tools. It is an independent community project—not an official Omarchy port or distribution.

## What it installs

- **yabai + skhd** — BSP tiling and keyboard-driven window control
- **SketchyBar + SbarLua** — a fast, event-driven Lua bar with desktops, focused app, weather, Notion Calendar's upcoming-meetings menu, system metrics, volume, battery, and time
- **JankyBorders** — active-window focus outline matched to macOS corners
- **Ghostty + tmux** — Osaka Jade terminal and persistent sessions
- **Neovim + LazyVim** — polished keyboard-first editing
- **Yazi** — terminal file manager
- **Raycast** — application launcher and system command center
- **CleanShot X** — screenshots, annotation, scrolling capture, recording, OCR, and a Quick Access Overlay (license or Setapp required)
- **Lazygit, GitHub CLI, Delta** — Git workflow
- **ripgrep, fd, jq, mise** — modern developer utilities
- **Firecrawl CLI** — web search and extraction tooling
- **JetBrainsMono Nerd Font** and the Osaka Jade color system
- **Kósmos Command Center** — themes, capture/OCR/QR, transcoding, reminders, notices, snapshots, health checks, and dev layouts

## Requirements

- macOS on Apple Silicon (Intel may work but is not yet tested)
- An administrator account
- Internet access
- Xcode Command Line Tools (Homebrew normally prompts to install them)
- Roughly 15 minutes, including macOS permission approval

## Install

Clone the repository so you can inspect exactly what will run:

```sh
git clone https://github.com/therealasclepius/kosmos-macos.git
cd kosmos-macos
./install.sh
```

Preview every installation action without changing the computer:

```sh
./install.sh --dry-run
```

The installer backs up existing managed configuration files under:

```text
~/.local/state/kosmos/backups/
```

## Required macOS permissions

Apple does not permit installers to approve privacy access. After installation, run:

```sh
./scripts/permissions.sh
```

Enable yabai, skhd, and your terminal under **System Settings → Privacy & Security → Accessibility**. If prompted, enable SketchyBar under **Screen & System Audio Recording**. Restart the affected applications afterward.

Then verify the environment:

```sh
kosmos doctor
kosmos test --live
```

If the desktop stack ever stops responding, restart and verify it with:

```sh
kosmos restart
```

## Everyday use

Press `Option + Return` for Ghostty or `Shift + Option + Return` for the persistent `main` tmux workspace. Press `Shift + Option + Y` for Yazi and `Shift + Option + V` for Neovim.

Open Raycast and search for “Kósmos” to access status, themes, OCR, QR scanning, a color picker, reminders, and the searchable shortcut sheet. The same tools are available from a terminal:

```sh
kosmos help
kosmos status
kosmos theme set osaka-jade
kosmos capture text
kosmos reminder add 20m "Check the oven"
kosmos dev layout codex
```

See [docs/command-center.md](docs/command-center.md) for the full CLI and [docs/shortcuts.md](docs/shortcuts.md) for the complete key map.

## Themes

Kósmos ships with two coherent themes that change SketchyBar, borders, Ghostty, tmux, Starship, Neovim, the macOS accent, and wallpaper together:

```sh
kosmos theme list
kosmos theme set osaka-jade
kosmos theme set kosmos
```

## Update

```sh
kosmos update
```

Updates create a configuration snapshot first, refuse to run over uncommitted repository changes, pull with fast-forward only, install declared dependencies, and apply versioned migrations. Set `KOSMOS_UPGRADE_PACKAGES=true` only when you also want to upgrade every Homebrew package.

Create or restore snapshots directly with:

```sh
kosmos snapshot create before-experiment
kosmos snapshot list
kosmos snapshot restore ~/.local/state/kosmos/snapshots/ARCHIVE.tar.gz --yes
```

## Uninstall

```sh
./uninstall.sh
```

The uninstaller removes only symlinks owned by this repository. Packages and system preferences remain in place to avoid unexpectedly deleting software or personal preferences. Pre-install files remain in the timestamped backup directory.

## Philosophy

Kósmos is Greek for order: a system whose parts form a coherent whole. The project brings that idea to macOS through sensible defaults, visible state, and a workflow that keeps both hands on the keyboard.

## Theme credit

The Osaka Jade palette and wallpaper come from [Justikun's Omarchy Osaka Jade theme](https://github.com/Justikun/omarchy-osaka-jade-theme), created by Justin Lowry and used under the MIT License. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

MIT
