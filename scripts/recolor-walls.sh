#!/usr/bin/env bash
# Build palette wallpapers: ~/wallpaper/monochrome_filter/wallhaven-<name>.png -> ~/wallpaper/palette/<name>.png
# Default recipe: -auto-level (sources use grey 10-15 as "black" -> stretch to 0),
# then +level-colors maps black->bg #0c0c0c, white->fg #d6d6d6.
set -euo pipefail
here="$(dirname "$(realpath "$0")")"
src=~/wallpaper/monochrome_filter; out=~/wallpaper/palette
mkdir -p "$out"

default() { magick "$1" -colorspace Gray -auto-level +level-colors '#0c0c0c,#d6d6d6' "$2"; }

# katana: re-rendered with the brightness-ramp ASCII script (thin chars, palette mid).
katana() { python3 -I "$here/ascii-ramp.py" "$1" "$2" --cols 260 >/dev/null; }

# shark: add depth. Multiply by (a) local glyph density (blur) so sparse ": ." fringes go dark,
# (b) a top-light vertical gradient so fins/belly fall off. White capped below fg.
shark() {
  magick "$1" -colorspace Gray -auto-level \
    \( +clone -blur 0x14 -auto-level +level 25%,100% \) -compose Multiply -composite \
    \( -size 2560x1600 gradient:'#ffffff-#5a5a5a' \) -compose Multiply -composite \
    +level-colors '#0c0c0c,#c0c0c0' "$2"
}

for f in "$src"/wallhaven-*.png; do
  n=$(basename "$f" .png); n=${n#wallhaven-}
  case $n in
    lain)   continue ;;                 # icon only, not a wallpaper
    katana) katana  "$f" "$out/$n.png" & ;;
    shark)  shark   "$f" "$out/$n.png" & ;;
    *)      default "$f" "$out/$n.png" & ;;
  esac
done
wait
ls "$out"
