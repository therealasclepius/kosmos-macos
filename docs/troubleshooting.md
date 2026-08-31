# Troubleshooting

Start with:

```sh
./scripts/doctor.sh
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

## Two menu bars are visible

Set **Automatically hide and show the menu bar** to **Always** in System Settings. The Apple menu bar remains accessible by moving the pointer to the top edge.

## Desktop shortcuts fail

Kósmos maps Desktops 1–9, but macOS must already have those desktops. Create them in Mission Control. Also disable conflicting macOS shortcuts under **Keyboard → Keyboard Shortcuts → Mission Control**.

## LazyVim plugins are not present yet

The first `nvim` launch downloads its plugin manager and plugins. Internet access is required. Inside Neovim, use `:Lazy` to inspect installation progress.

## Restore an older configuration

Installer backups are timestamped under:

```text
~/.local/state/kosmos/backups/
```

Run `./uninstall.sh`, then copy the desired backup files into their original locations.
