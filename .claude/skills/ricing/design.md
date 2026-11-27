---
description: My taste, decisions, inspo summary and system facts for ricing. Read this instead of re-parsing rice-refs.
---

# Taste (rules)
1. **Monochrome, dark, neutral grey.** Near-black bg, off-white fg, pure greys between. No accent colors, no warm/sepia tint.
2. **Readability beats aesthetics.** Never dark-on-dark or grey-on-grey for text. Thin fonts need bigger size or bold.
3. **Retro / old-terminal / ASCII vibe.** Wallpapers are my ASCII-art images, recolored to the palette.
4. **Font:** Courier-style serif mono. Nimbus Mono PS Regular is hairline-thin → too faint for `dim` text; prefer its Bold weight or Courier Prime (heavier strokes).
5. **Everything matches.** Firefox, Obsidian, Dolphin, GTK/Qt apps follow the palette so nothing breaks immersion. No global e-ink shader (overkill).
6. **Launcher:** wofi only (no rofi/hyprlauncher).
7. **Window borders:** undecided. Idea: gradient or something thematic. Decide after palette + wallpaper exist.

# Widgets I want (Quickshell)
- **Left bar:** time + workspaces. Text-only.
- **Power widget:** transparent; actions = lock, screen off (idle), suspend, power off.
- **All widgets animated:** on hover they grow and reveal more info.

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

# System facts (as of 2026-11-27)
- Hyprland 0.57.2, **Lua config** (`hl.config`, `hl.bind`, …); API stubs: `/usr/share/hypr/stubs/hl.meta.lua`.
- Quickshell 0.3.2 / Qt 6.12, kitty 0.51.1, wofi 1.5.3, hyprpaper 0.8.5, hyprlock 0.9.7, hypridle 0.1.8, mako 1.11 (D-Bus activated), imagemagick 7.
- Dotfiles: stow packages `hypr kitty wofi quickshell bash fastfetch fontconfig` (`<pkg>/.config/<pkg>` → `~/.config/<pkg>`), relink with `./stow.sh`.
- `.claude/` is excluded via `.git/info/exclude` (local, unversioned) except `.claude/skills/ricing/*.md` → design.md + SKILL.md are tracked; ref images are not.

# Progress (handoff — read this first in a new session)
Workflow: user dictates each step; do only that, verify (reload + screenshot via `grim -s 0.5`), report, stop. Ask before editing.
- [x] 0 hygiene: .idea untracked, dead symlinks removed, `stow.sh` (idempotent `stow -R`).
- [x] 1 palette: `palette.md` (bg #0c0c0c, surface #161616, line #3a3a3a, dim #808080, mid #a8a8a8, fg #d6d6d6, bright #f0f0f0).
- [x] 2 hypr look (`core.lua`): no blur/shadow, gaps 10/30, border fg/line, no mascot. Rounding still 10 (borders = step 13).
- [x] 3 wallpaper: `scripts/recolor-walls.sh` → `~/wallpaper/palette/`; per-workspace switching via `wallpaper.lua` (verified working).
      Mapping ws1 katana, 2 shark, 3 dying_man, 4 angel, 5 woman_blueish, 6-10 wrap (woman_red dropped: darker duplicate).
- [x] 4 kitty: Courier Prime Code 12 (bold = Courier Prime SemiBold); `theme.conf` (included) = 16 ANSI as palette greys
      (red=bright, green/blue/mag/cyan=mid, yellow=fg, slot 8=dim, slot 0=surface), inverted selection, block cursor + cursor_trail.
      Font was silently Noto until `fontconfig/fonts.conf` marked Courier Prime (Code) spacing=mono (files lack isFixedPitch).
      fastfetch on kitty open (`bash/.bashrc`, FASTFETCH_SHOWN guard), arch_small logo, colors as raw SGR 90/37/97
      (fastfetch's bright_* names = bold+normal → slot 0 → invisible). Reload kitty = `kill -USR1 $(pgrep -x kitty)`.
      Not done (user didn't pick): padding, text_composition_strategy, tab bar styling.
- [ ] 5 wofi: style.css (palette, square, inverted selection); `menu = "wofi"` in programs.lua; cliphist bind rofi → `wofi --dmenu`.
- [ ] 6 mako: palette colors/border (currently default blue).
- [x] 7 Quickshell left bar v1 (`LeftBar.qml`, 40px, opaque bg + 1px line edge): workspaces via Hyprland.workspaces (focused = inverted, click = activate),
      SystemClock (Minutes) HH over MM at bottom; autostart `qs` on hyprland.start (programs.lua). Order changed: Quickshell before wofi/mako.
      v2 (caelestia/soramane layout, squared): bottom-up power (2-click arm, 3 s) · [wifi bt] on surface plate w/ line border
      (Quickshell.Networking/Bluetooth over D-Bus, click toggles radio) · clock · calendar btn → PopupWindow + `Calendar.qml`
      (Mon-first grid, today inverted, HyprlandFocusGrab closes on outside click). Icons = ProggyClean CE Nerd Font Mono 26px.
      Qt warning: quickshell 0.3.2-1 built vs Qt 6.12.0, system 6.12.1 → reinstall doesn't fix, needs repo rebuild.
- [x] 7b popup animation: `BlobPopup.qml` (calendar + power) scales 0.1→1 from the source icon centre (Scale.origin via mapToItem at open),
      OutBack 260 ms open / InCubic 140 ms close, unmap after close anim. Drive `open`, never `visible`.
- [ ] 7c hypr windowsIn blob (Plan B, not done): `popin 60%` + underdamped spring (ζ≈0.55–0.6, k=300 c≈19); windowsOut linear no bounce.
- [ ] 8 bar hover-expand animation (Behavior/NumberAnimation); keep exclusiveZone fixed so expansion overlays, no window reflow.
- [ ] 9 power widget: transparent, hover-expand → lock (hyprlock) / screen off (dpms off) / suspend / poweroff; hypridle config.
- [ ] 10 hyprlock theme.  - [ ] 11 apps one by one: GTK3/4, Dolphin (kdeglobals), Firefox userChrome, Obsidian snippet, cursor.
- [ ] 12 optional analog clock widget (QML Canvas).  - [ ] 13 window border design (user idea: gradient / thematic).
- [ ] maybe: Lain as small corner icon (Quickshell Image).

# Notes
- Wallpapers: the source images in `~/wallpaper/` ARE already ASCII art. Default = recolor only (auto-level, black→bg, white→fg).
  Per-image recipes in `recolor-walls.sh`: katana = `scripts/ascii-ramp.py --cols 260` (thin brightness-ramp chars, user's favourite);
  shark = density-blur × top-light gradient (depth in greys, white capped #c0c0c0).
- REJECTED: edge-mode ASCII (strong `\ | / -` chars) → user hated it. Thinning glyphs by erosion → breaks letters. Inverted renders → wall of chars.
- Per-workspace wallpaper: `hl.on("workspace.active", fn(ws))` — callback gets the workspace object (ws.id, ws.monitor.name, ws.special).
  hyprpaper = systemd user unit; check with `hyprctl hyprpaper listactive`; logs `journalctl --user -u hyprpaper`.
- Gotchas: sudo needs a real terminal (the `!` prefix has no TTY) → user runs sudo in kitty. Never `pkill -f <pattern>` from a shell
  whose own cmdline contains the pattern. ImageMagick label text: avoid `%`, double `\`.
- Lain (`wallhaven-lain.png`): not a wallpaper. Maybe later as a small corner icon/widget. Undecided.
