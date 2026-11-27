---
description: My taste, decisions, inspo summary and system facts for ricing. Read this instead of re-parsing rice-refs.
---

# Taste (rules)
1. **Monochrome, dark, neutral grey.** Near-black bg, off-white fg, pure greys between. No accent colors, no warm/sepia tint.
2. **Readability beats aesthetics.** Never dark-on-dark or grey-on-grey for text. Thin fonts need bigger size or bold.
3. **Retro / old-terminal / ASCII vibe.** Wallpapers are my ASCII-art images, recolored to the palette.
4. **Font:** Courier-style serif mono. Nimbus Mono PS Regular is hairline-thin → too faint for `dim` text; prefer its Bold weight or Courier Prime (heavier strokes).
5. **Everything matches.** Firefox, Obsidian, Dolphin, GTK/Qt apps follow the palette so nothing breaks immersion. No global e-ink shader (overkill).
6. **Launcher:** wofi only (no rofi/hyprlauncher). Rejected a Quickshell-native launcher; consequence: wofi can't get the
   concave frame joins (separate GTK surface) — revisit only if seamless wofi fusion becomes a must.
7. **Window borders:** undecided. Idea: gradient or something thematic. Decide after palette + wallpaper exist.

# Widgets I want (Quickshell)
- **Left bar:** time + workspaces. Text-only.
- **Power widget:** transparent; actions = lock, screen off (idle), suspend, power off.
- **All widgets animated:** on hover they grow and reveal more info.
- **Frame look (Caelestia, `rice-refs/shell`):** bar + 8 px strips around the screen in one fill (#262626), rounded inner
  corners; every popup/launcher is fused to the frame (same fill, no outline, rounded outer corner, concave joins)
  and its edges snap to bar-element edges (never cut through an icon).

# What defines the inspo (rice-refs/inspiration_screenshots)
- Duotone: one bg + one fg. Highlight = inversion (swap fg/bg) for active workspace, selection, status lines.
- Hard rectangular windows: solid border, no shadow/blur/gradient. Large gaps; windows float over a high-contrast 1-bit-style wallpaper with lots of negative space.
- Text-only top bar: `1 2 3 …  15:56:26 2026-05-28`.
- Desktop widgets: analog clock with tick marks, small boxed info panes (fetch).
- Typewriter mono (cterm shots) or Chicago-style bitmap (classic-Mac shot).
- BAREBLOOD (KDE gothic, red) = reference for "everything themed", not for colors.
- Shots 1–3 are colored duotones (orange/red, yellow/black, blue/cream) — I take the *structure*, not the colors.

# Refs layout
- `rice-refs/wallpaper/` originals (source: `~/wallpaper/`), `wallpaper/monochrome_filter/` greyscale versions.
- `rice-refs/inspiration_screenshots/` 7 shots. `rice-refs/BAREBLOOD/` full KDE theme repo.
- `rice-refs/shell/` = Caelestia shell source (Quickshell). Frame logic: `modules/drawers/` (ContentWindow = one fullscreen
  surface + input mask + SDF blobs, Exclusions = 1×1 exclusiveZone windows, Regions = mask). Launcher in `modules/launcher/`.
- All refs live in `.claude/skills/ricing/rice-refs/` (untracked).

# System facts (as of 2026-11-27)
- Hyprland 0.57.2, **Lua config** (`hl.config`, `hl.bind`, …); API stubs: `/usr/share/hypr/stubs/hl.meta.lua`.
- Quickshell 0.3.2 / Qt 6.12, kitty 0.51.1, wofi 1.5.3, hyprpaper 0.8.5, hyprlock 0.9.7, hypridle 0.1.8, mako 1.11 (D-Bus activated), imagemagick 7.
- Dotfiles: stow packages `hypr kitty wofi quickshell bash fastfetch fontconfig mako` (`<pkg>/.config/<pkg>` → `~/.config/<pkg>`), relink with `./stow.sh`.
- `.claude/` is excluded via `.git/info/exclude` (local, unversioned) except `.claude/skills/ricing/*.md` → design.md + SKILL.md are tracked; ref images are not.

# Progress (handoff — read this first in a new session)
Workflow: user dictates each step; do only that, verify (reload + screenshot via `grim -s 0.5`), report, stop. Ask before editing.
- [x] 0 hygiene: .idea untracked, dead symlinks removed, `stow.sh` (idempotent `stow -R`).
- [x] 1 palette: `palette.md` (bg #0c0c0c, surface #161616, line #3a3a3a, dim #808080, mid #a8a8a8, fg #d6d6d6, bright #f0f0f0).
- [x] 2 hypr look (`core.lua`): no blur/shadow, gaps 10/30, border fg/line, no mascot. Rounding still 10 (borders = step 13).
- [x] 3 wallpaper: `scripts/recolor-walls.sh` → `~/wallpaper/palette/`; per-workspace switching via `wallpaper.lua` (verified working).
      Mapping ws1 angel, 2 woman_blueish, 3 dying_man, 4 katana, 5 shark, 6-10 wrap (hyprpaper.conf start = angel) (woman_red dropped: darker duplicate).
- [x] 4 kitty: Courier Prime Code 12 (bold = Courier Prime SemiBold); `theme.conf` (included) = 16 ANSI as palette greys
      (red=bright, green/blue/mag/cyan=mid, yellow=fg, slot 8=dim, slot 0=surface), inverted selection, block cursor + cursor_trail.
      Font was silently Noto until `fontconfig/fonts.conf` marked Courier Prime (Code) spacing=mono (files lack isFixedPitch).
      fastfetch on kitty open (`bash/.bashrc`, FASTFETCH_SHOWN guard), arch_small logo, colors as raw SGR 90/37/97
      (fastfetch's bright_* names = bold+normal → slot 0 → invisible). Reload kitty = `kill -USR1 $(pgrep -x kitty)`.
      Not done (user didn't pick): padding, text_composition_strategy, tab bar styling.
- [x] 5 wofi = bottom launcher: `wofi/launch.sh` (dmenu + fuzzy; app names cached in ~/.cache/wofi-apps, rebuilt when an
      applications dir mtime is newer; 0 matches or "?" prefix → Google in zen-browser; `--open` = no toggle). Opened by SUPER+SPACE
      (toggle) and the Frame bottom strip. `clip.sh` = cliphist via print_line_num.
      style.css: fill = frame colour (hardcoded, keep in sync with Theme.qml), no outline; y=-16 → flush on the bottom strip
      (wofi adds 16 px and also respects the strip's exclusive zone). Hypr layer rule `slide bottom` on ns wofi.
      TODO later: monochrome ASCII-style icons for important apps (dmenu supports `img:<path>:text:<name>` + allow_images).
- [x] 6 mako (`mako/.config/mako/config`, stow pkg): frame #262626 fill, 1px line border, radius 10, Courier Prime 12,
      `icons=0` (kitty icon came from desktop-entry=kitty on Claude Code notifs), top-right, low=mid text, critical=bright border+text, no timeout.
- [x] 7 Quickshell left bar v1 (`LeftBar.qml`, 40px, opaque bg + 1px line edge): workspaces via Hyprland.workspaces (focused = inverted, click = activate),
      SystemClock (Minutes) HH over MM at bottom; autostart `qs` on hyprland.start (programs.lua). Order changed: Quickshell before wofi/mako.
      v2 (caelestia/soramane layout, squared): bottom-up power · [wifi bt] on full-width surface plate (no border)
      (Quickshell.Networking/Bluetooth over D-Bus, click toggles radio) · clock · calendar btn → PopupWindow + `Calendar.qml`
      (Mon-first grid, today inverted, HyprlandFocusGrab closes on outside click). Icons = ProggyClean CE Nerd Font Mono 26px.
      Qt warning: quickshell 0.3.2-1 built vs Qt 6.12.0, system 6.12.1 → reinstall doesn't fix, needs repo rebuild.
- [x] 7b frame (Caelestia architecture, squared strips): `Theme.qml` singleton (frame #262626 = palette `frame`, bar 40, border 8,
      rounding 16). `Frame.qml` = ONE fullscreen surface (exclusionMode Ignore → fixed geometry; separate strip surfaces moved on
      hot reload because layer arrange order changed) drawing top/right/bottom strips + 4 `Fillet.qml` concave inner corners
      (Canvas, drawn top-left, rotated); input mask = strips only. 3 invisible 1×1 `frame-exclusion` windows carry exclusiveZone 8
      → `hyprctl monitors` reserved [40,8,8,8]. Bottom strip = launcher hot zone (250 ms dwell). Bar fill = Theme.frame.
      Popups = `DrawerPopup.qml` (callers set boxWidth/boxHeight): flush to bar + bottom strip, frame fill, topRightRadius 16,
      concave Fillets at bar↔top and right↔bottom strip (surface +R top/right, mask = box), slide out from behind the bar
      (OutQuint 240 ms, clip), unmap after close anim; drive `open`, never `visible`. Height snapped by `bar.snapHeight(h)` to the
      top of a bottomStack element (property-based → reactive). BlobPopup (scale + overshoot) dropped: gap to the bar.
      Tried: frame #3a3a3a (too light), #0c0c0c (vanishes into wallpaper). Dim text on frame #808080 → #a8a8a8. gaps_out 30 → 12.
      Popup visuals verified only via config load — user clicks to check.
      Next idea: wofi `border-radius` on top corners (joins to the strip stay square).- [ ] 7c hypr windowsIn blob (Plan B, not done): `popin 60%` + underdamped spring (ζ≈0.55–0.6, k=300 c≈19); windowsOut linear no bounce.
- [ ] 8 bar hover-expand animation (Behavior/NumberAnimation); keep exclusiveZone fixed so expansion overlays, no window reflow.
- [ ] 9 power widget: transparent, hover-expand → lock (hyprlock) / screen off (dpms off) / suspend / poweroff; hypridle config.
- [ ] 10 hyprlock theme.
- [x] 11a GTK + font + icons: stow pkg `gtk` → `gtk-3.0/gtk.css` = palette as libadwaita named colours (accent = inversion,
      headerbar = frame, sidebar/cards = surface, error/warn = greys); `gtk-4.0/gtk.css` @imports it. Needs theme adw-gtk3-dark
      (built-in Adwaita GTK3 compiles literal colours → ignores @define-color). dconf (not in dotfiles): gtk-theme adw-gtk3-dark,
      color-scheme prefer-dark, font-name "Rice Mono 11", monospace-font-name "Courier Prime Code 11", icon-theme Papirus-Mono.
      **Font variable:** fontconfig alias `Rice Mono` → Courier Prime (fonts.conf); used by wofi, mako, GTK, Quickshell (`Theme.font`).
      kitty stays explicit (Code variant + SemiBold bold). Switch font = fonts.conf + kitty.conf, `fc-cache -f`, restart apps.
      **Icons:** `scripts/mono-icons.py` → ~/.local/share/icons/Papirus-Mono (places/mimetypes/devices, every hex → luma grey
      in [#50,#e0], inherits Papirus-Dark for the rest). Re-run after papirus updates.
      dconf values are reapplied by `scripts/gsettings.sh` (run from stow.sh; also builds Papirus-Mono if missing).
- [x] 11b Zen (profile = `[Install…] Default=` in ~/.zen/profiles.ini): `zen/` dir, symlinked by `scripts/link-zen.sh`
      (stow can't target the random profile dir; run from stow.sh). `user.js` = stylesheets pref, dark scheme, default fonts
      Rice Mono. `chrome/userChrome.css` overrides Zen vars (--zen-main-browser-background = frame #262626, --zen-colors-*,
      toolbar/panel greys, AccentColor → fg) with !important (beats the workspace-gradient JS); active tab inverted.
      Var names come from omni.ja zen-styles/zen-theme.css → recheck after big Zen updates.
      Pages: Dark Reader, settings in `zen/darkreader.json` (import manually; grayscale 100, bg/fg = palette).
      SKIPPED (user, 2026-11-27): about: pages (about:addons, settings) stay navy/accent-coloured; fix would be
      `userContent.css` scoped with @-moz-document url-prefix("about:"). Dark Reader import not confirmed.
- [ ] 11c Zotero (NEXT; zotero-bin 9.0.4, Firefox/Gecko-based → same mechanism as Zen):
      profile = ~/.zotero/zotero/<random>.default (profiles.ini) → extend `link-zen.sh`-style linking (or a link-zotero.sh).
      user.js: toolkit.legacyUserProfileCustomizations.stylesheets = true (+ dark scheme pref).
      chrome/userChrome.css: palette greys for item tree, collections pane, item pane, tabs; selection = inversion.
      Reader "e-ink": Zotero's reader appearance/theme setting (bg/fg per theme) → grey page bg + fg text; verify that
      custom themes exist in v9 before relying on it. Fallback = reader-only CSS filter (grayscale + invert) in userContent.
      Global screen_shader stays rejected.
- [ ] 11 rest (order): Obsidian snippet → cursor.
      Firefox dropped (Zen is the browser). Per-app e-ink via Hyprland `screen_shader` REJECTED again: it's output-global,
      a focus-swap hack shades bar/frame/other windows and flickers.
- [ ] 12 optional analog clock widget (QML Canvas).  - [ ] 13 window border design (user idea: gradient / thematic).
- [ ] maybe: Lain as small corner icon (Quickshell Image).

# Notes
- Wallpapers: the source images in `~/wallpaper/` ARE already ASCII art. Default = recolor only (auto-level, black→bg, white→fg).
  Per-image recipes in `recolor-walls.sh`: katana = `scripts/ascii-ramp.py --cols 260` (thin brightness-ramp chars, user's favourite);
  shark = density-blur × top-light gradient (depth in greys, white capped #c0c0c0).
- REJECTED: edge-mode ASCII (strong `\ | / -` chars) → user hated it. Thinning glyphs by erosion → breaks letters. Inverted renders → wall of chars.
- Per-workspace wallpaper: `hl.on("workspace.active", fn(ws))` — callback gets the workspace object (ws.id, ws.monitor.name, ws.special).
  hyprpaper = systemd user unit; check with `hyprctl hyprpaper listactive`; logs `journalctl --user -u hyprpaper`.
- Hypr extras (user, 2026-11-27): launcher bind SUPER+SPACE (was SUPER+R), SUPER+F float toggle; active/inactive opacity 0.92
  (kitty override 1.0 + its own background_opacity 0.85 → opaque text; YouTube/Netflix titles opaque; fullscreen 1.0);
  built-in wobble (0.57) on floating windows only (rule no-wobble-tiled); touchpad tap/drag/drag_lock; border grab 25 px.
- Gotchas: sudo needs a real terminal (the `!` prefix has no TTY) → user runs sudo in kitty. Never `pkill -f <pattern>` from a shell
  whose own cmdline contains the pattern. ImageMagick label text: avoid `%`, double `\`.
- Lain (`wallhaven-lain.png`): not a wallpaper. Maybe later as a small corner icon/widget. Undecided.
