# Troubleshooting

Start with:

```sh
kosmos doctor
```

To restart and re-check the complete desktop stack:

```sh
kosmos restart
```

## Shortcuts do nothing

Open **System Settings → Privacy & Security → Accessibility** and confirm that skhd, yabai, and the terminal used to install Kósmos are enabled. Toggle an entry off and on, then restart the services:

```sh
skhd --restart-service
yabai --restart-service
```

## Windows do not tile

Confirm yabai has Accessibility access, then select BSP mode with `Control + Option + B`. Some dialogs, preference panels, and non-resizable application windows cannot tile normally.

## SketchyBar is missing

```sh
brew services restart sketchybar
```

If macOS requests Screen Recording, grant it under **Privacy & Security → Screen & System Audio Recording**, then restart SketchyBar.

If `kosmos doctor` reports that the SbarLua module is missing, rebuild the pinned version and restart the bar:

```sh
./scripts/install-sbarlua.sh
brew services restart sketchybar
```

## Two menu bars are visible

Set **Automatically hide and show the menu bar** to **Always** in System Settings. The Apple menu bar remains accessible by moving the pointer to the top edge.

## Desktop shortcuts fail

Kósmos maps Desktops 1–9, but macOS must already have those desktops. Create them in Mission Control. Also disable conflicting macOS shortcuts under **Keyboard → Keyboard Shortcuts → Mission Control**.

## Desktop icons are hidden

Disabling Finder's desktop layer keeps the wallpaper clean, but yabai may not be able to focus a completely empty Space reliably. Kósmos leaves the desktop layer enabled by default. To hide it deliberately:

```sh
defaults write com.apple.finder CreateDesktop -bool false
killall Finder
```

Restore the most reliable yabai behavior with:

```sh
defaults write com.apple.finder CreateDesktop -bool true
killall Finder
```

## Command-Shift-4 seems to do nothing

Kósmos maps `Command-Shift-3/4/5` to CleanShot X. Complete CleanShot's first-run license or Setapp activation and allow **Screen & System Audio Recording** when macOS asks.

If CleanShot is unavailable, Kósmos redirects normal macOS screenshots to:

```text
~/Pictures/Kosmos Captures
```

Restore that visible destination and restart the menu service with:

```sh
mkdir -p "$HOME/Pictures/Kosmos Captures"
defaults write com.apple.screencapture location "$HOME/Pictures/Kosmos Captures"
defaults write com.apple.screencapture show-thumbnail -bool true
killall SystemUIServer
```

If the crosshair never appears, enable the screenshot shortcuts under **System Settings → Keyboard → Keyboard Shortcuts → Screenshots**.

## LazyVim plugins are not present yet

The first `nvim` launch downloads its plugin manager and plugins. Internet access is required. Inside Neovim, use `:Lazy` to inspect installation progress.

## Raycast does not show Kósmos commands

In Raycast Settings, open **Extensions → Script Commands** and confirm this directory is present:

```text
~/Documents/Raycast Script Commands
```

Use Raycast's **Reload Script Directories** command, then search for “Kósmos”. OCR and QR capture require Raycast under **Privacy & Security → Screen & System Audio Recording**.

## The terminal prompt is duplicated

Kósmos sources its shell workflow from the marked block in `~/.zshrc`. Remove older, separate `starship init`, `zoxide init`, `fzf --zsh`, or `mise activate` lines if you previously configured those tools yourself.

## Restore an older configuration

Installer backups are timestamped under:

```text
~/.local/state/kosmos/backups/
```

For a Kósmos snapshot, use `kosmos snapshot list` followed by `kosmos snapshot restore ARCHIVE --yes`. For a pre-install backup, run `./uninstall.sh`, then copy the desired files into their original locations.
