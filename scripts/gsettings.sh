#!/usr/bin/env bash
# GTK/desktop settings live in dconf (binary db, not a dotfile) → reapply from here. Idempotent.
# GTK on Wayland reads these via GSettings, not gtk-3.0/settings.ini.
set -euo pipefail
cd "$(dirname "$0")"
s=org.gnome.desktop.interface
[[ -d ~/.local/share/icons/Papirus-Mono ]] || python -I ./mono-icons.py   # grey icon theme (generated)
gsettings set $s gtk-theme           'adw-gtk3-dark'          # pacman: adw-gtk-theme
gsettings set $s color-scheme        'prefer-dark'            # libadwaita / portal dark mode
gsettings set $s icon-theme          'Papirus-Mono'           # pacman: papirus-icon-theme
gsettings set $s font-name           'Rice Mono 11'           # fontconfig alias (fonts.conf)
gsettings set $s monospace-font-name 'Courier Prime Code 11'
