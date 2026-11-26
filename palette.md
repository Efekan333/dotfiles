# Palette — monochrome, dark, neutral

Single source of truth. Per-app configs copy these values by hand (until a generator exists).
Contrast = WCAG ratio vs `bg`. Text needs ≥ 4.5.

| name    | hex       | vs bg | use                                                      |
|---------|-----------|-------|----------------------------------------------------------|
| bg      | `#0c0c0c` | 1.0   | window/terminal/bar background                           |
| surface | `#161616` | 1.1   | raised panels, hover bg, inactive tabs (never for text)  |
| line    | `#3a3a3a` | 1.7   | inactive borders, separators (never for text)            |
| dim     | `#808080` | 5.0   | secondary text: comments, inactive workspaces, hints     |
| mid     | `#a8a8a8` | 8.2   | tertiary emphasis, active-but-unfocused border           |
| fg      | `#d6d6d6` | 13.5  | normal text, focused border                              |
| bright  | `#f0f0f0` | 17.2  | emphasis, bold, inverted-highlight background            |

## Rules
- **Highlight = inversion:** `bright` bg + `bg` text (contrast 17.2). No accent colors.
- `surface` and `line` are for shapes only. Text on them must be `dim` or lighter.
- No pure `#000`/`#fff`: 21:1 causes halation (glyphs bleed) with thin serif mono strokes.
- Transparency: use `bg` with alpha (e.g. `#cc0c0c0c` / `rgba(12,12,12,0.8)`), keep text opaque.
