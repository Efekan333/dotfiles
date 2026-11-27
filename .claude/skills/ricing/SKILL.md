---
description: Use when designing or changing my Hyprland, Quickshell, Kitty or Wofi setup.
---

# Context budget: read only what this step needs
1. Read [design.md](design.md) first. It already summarizes my taste, the inspo screenshots,
   versions, decisions, rejected ideas and progress. Treat it as the source of truth.
2. Then read ONLY the config file(s) of the component this step changes (e.g. step 4 → kitty.conf + palette.md).
   Don't explore the repo, don't re-read other configs "for context".
3. Do NOT open images in `rice-refs/` or `~/wallpaper/` unless I ask, or design.md truly lacks what the step needs.
4. Check installed versions/docs only for the component being changed, and only if the syntax is uncertain.
5. Screenshots for verification: at most one `grim -s 0.5` per change, cropped to the relevant area when possible.
   Don't re-read a screenshot already reviewed.

# Workflow
- I dictate the step. Do only that step, verify it, report concisely, then stop and wait.
- Change one component at a time, then verify it.
- After milestones (an entire color palette, an entire widget) git add and commit.
- Before ending a session or when I ask: update the Progress section in design.md so the next session can continue from it.

# Paths
- Refs root: `.claude/skills/ricing/rice-refs/` (untracked). Wallpaper sources: `~/wallpaper/` (copies in `rice-refs/wallpaper/`).
  Inspo: `rice-refs/inspiration_screenshots/`. Caelestia shell source (frame/drawer reference): `rice-refs/shell/`.
- Quickshell shared values: `quickshell/.config/quickshell/Theme.qml`; wofi duplicates the frame colour in `style.css`.

# Verification gotchas
- Quickshell hot-reloads on save; a "Failed to load" right after a write is usually a half-written file → check the next reload line.
- Popups only open on a real click → can't screenshot them; say so and let me check.
