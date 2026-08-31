#!/bin/bash
set -euo pipefail

printf '\nKósmos needs macOS approval for keyboard and window control.\n'
printf 'Add and enable yabai, skhd, and your terminal under Accessibility.\n'
printf 'If SketchyBar requests Screen Recording, enable it there as well.\n\n'

open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'
printf 'After approving Accessibility, open Screen Recording if macOS requested it:\n'
printf 'System Settings → Privacy & Security → Screen & System Audio Recording\n'
printf '\nRestart affected applications after granting access.\n'
