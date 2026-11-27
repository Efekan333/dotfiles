#!/usr/bin/env bash
# Clipboard history in wofi. cliphist lines are "<id>\t<preview>"; we show only the preview and
# map the chosen line number back to the full line (print_line_num), so the id never shows up.
# (pre_display_cmd would fork a shell per entry → slow with hundreds of entries.)
set -u
list=$(cliphist list) || exit 0
n=$(cut -f2- <<<"$list" | wofi --dmenu --location=bottom --prompt="clipboard" \
        --no-custom-entry -D dmenu-print_line_num=true) || exit 0
sed -n "$((n + 1))p" <<<"$list" | cliphist decode | wl-copy
