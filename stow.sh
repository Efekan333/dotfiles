#!/usr/bin/env bash
# (Re)link every package into $HOME. Idempotent: -R unlinks then relinks.
# Package layout: <pkg>/.config/<pkg>  ->  ~/.config/<pkg>
set -euo pipefail
cd "$(dirname "$0")"
pkgs=(hypr kitty wofi quickshell bash fastfetch fontconfig mako gtk)
stow -v -R -t "$HOME" "${pkgs[@]}"
./scripts/gsettings.sh
./scripts/link-zen.sh
