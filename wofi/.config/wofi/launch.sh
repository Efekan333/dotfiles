#!/usr/bin/env bash
# Bottom launcher: fuzzy-search apps in wofi; Enter with 0 matches → Google the text in Zen.
# Prefix "?" forces web search ("?cat" matches no app name, so wofi returns the raw text).
#   launch.sh          toggle (SUPER+R): a second call closes it
#   launch.sh --open   only open (hot edge): hovering again must not close it
set -u

if pgrep -x wofi >/dev/null; then
    [[ ${1:-} == --open ]] || pkill -x wofi
    exit 0
fi

dirs=(/usr/share/applications "$HOME/.local/share/applications")
cache="${XDG_CACHE_HOME:-$HOME/.cache}/wofi-apps"     # lines: Name<TAB>desktop-id

# A dir's mtime changes when a file inside is created/removed (pacman install/uninstall),
# so one stat() per dir tells us whether the cache is stale. Editing a .desktop in place is not caught.
stale=1
if [[ -f $cache ]]; then
    stale=0
    for d in "${dirs[@]}"; do [[ -d $d && $d -nt $cache ]] && stale=1; done
fi
if ((stale)); then
    files=()
    for d in "${dirs[@]}"; do [[ -d $d ]] && files+=("$d"/*.desktop); done
    # One gawk process over all files (not one fork per file). Only the [Desktop Entry] section counts;
    # later dirs (~/.local) override system entries with the same name.
    gawk -F= '
        FNR == 1   { sec = ""; name = ""; skip = 0; app = 0 }
        /^\[/      { sec = $0; next }
        sec != "[Desktop Entry]" { next }
        $1 == "Name" && name == "" { name = substr($0, 6) }
        $1 == "Type" && $2 == "Application" { app = 1 }
        ($1 == "NoDisplay" || $1 == "Hidden") && $2 == "true" { skip = 1 }
        ENDFILE {
            if (name != "" && app && !skip) {
                id = FILENAME; sub(/.*\//, "", id); sub(/\.desktop$/, "", id)
                ids[name] = id
            }
        }
        END { for (n in ids) print n "\t" ids[n] }
    ' "${files[@]}" | sort -f >"$cache.tmp" && mv "$cache.tmp" "$cache"
fi

declare -A ids
while IFS=$'\t' read -r name id; do ids[$name]=$id; done <"$cache"

choice=$(cut -f1 "$cache" | wofi --dmenu --matching=fuzzy --location=bottom --prompt="app · ?web") || exit 0
[[ -z $choice ]] && exit 0

if [[ -n ${ids[$choice]:-} ]]; then
    exec gtk-launch "${ids[$choice]}"
fi
query=${choice#\?}
exec zen-browser "https://www.google.com/search?q=$(jq -rn --arg q "$query" '$q|@uri')"
