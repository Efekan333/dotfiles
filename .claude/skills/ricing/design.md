---
description: My taste, decisions, inspo summary and system facts for ricing. Read this instead of re-parsing rice-refs.
---

# Taste (rules)
1. **Monochrome, dark, neutral grey.** Near-black bg, off-white fg, pure greys between. No accent colors, no warm/sepia tint.
2. **Readability beats aesthetics.** Never dark-on-dark or grey-on-grey for text. Thin fonts need bigger size or bold.
3. **Retro / old-terminal / ASCII vibe.** Wallpapers are ASCII renders of my images (not plain greyscale).
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
- Dotfiles: stow packages `hypr kitty wofi quickshell` (`<pkg>/.config/<pkg>` → `~/.config/<pkg>`), relink with `./stow.sh`.
- `.claude/` is excluded via `.git/info/exclude` (local, unversioned) except `.claude/skills/ricing/*.md` → design.md + SKILL.md are tracked; ref images are not.

# Progress
- [x] 0 hygiene  - [x] 1 palette (`palette.md`)  - [x] 2 hypr look  - [~] 3 ASCII wallpaper (pipeline works; image/style TBD)  - [ ] 4 kitty
- [ ] 5 wofi  - [ ] 6 mako  - [ ] 7–8 left bar  - [ ] 9 power widget  - [ ] 10 hyprlock
- [ ] 11 apps  - [ ] 12 clock  - [ ] 13 borders

# Notes
- Wallpaper: `scripts/ascii-wall.py IN OUT --cols N` → `~/wallpaper/ascii/`; hyprpaper runs as systemd user unit (`journalctl --user -u hyprpaper`).
  Brightness→char ramp works for silhouettes (katana), fails on shaded art (lain = noise). Default is now `--mode edge` (Sobel structure tensor → - / | \ in fg, sparse fill in dim): outlines read. Lain is NOT a wallpaper candidate (see below), so no crop/zoom needed.
- Lain (`wallhaven-lain.png`): not a wallpaper. Maybe later as a small corner icon/widget (e.g. Quickshell). Undecided.
