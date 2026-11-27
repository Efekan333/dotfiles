#!/usr/bin/env bash
# Zen profile dir has a random name → stow can't target it. Symlink tracked files into the
# profile the launcher actually uses ([Install…] Default= in profiles.ini).
set -euo pipefail
src="$(cd "$(dirname "$0")/.." && pwd)/zen"
ini=~/.zen/profiles.ini
[[ -f $ini ]] || { echo "no Zen profile yet, skipping"; exit 0; }
prof=~/.zen/$(awk -F= '/^\[Install/{i=1} i&&/^Default=/{print $2; exit}' "$ini")
mkdir -p "$prof/chrome"
ln -sfn "$src/user.js"                "$prof/user.js"
ln -sfn "$src/chrome/userChrome.css"  "$prof/chrome/userChrome.css"
echo "linked into $prof"
