#!/usr/bin/env python3
"""Render an image as ASCII-art wallpaper (palette colors, monospace font).

usage: ascii-wall.py IN OUT [--mode edge|ramp] [--cols N] [--edge-pct P] [--size WxH]
                            [--font PATH] [--fg HEX] [--fill HEX] [--bg HEX] [--invert]

ramp: brightness -> character ramp (good for silhouettes).
edge: per cell, structure tensor of the Sobel gradient gives edge strength + direction.
      Strong cells get a line char (- / | \\) in --fg, the rest a sparse brightness
      ramp in --fill. Two text layers composited, so outlines read over shading.
"""
import argparse, subprocess, tempfile, os
import numpy as np
from PIL import Image, ImageFilter, ImageOps

RAMP = " .,:;-=+*x#&@"   # dark -> bright. No "%": ImageMagick escape char in label text
FILL = " .:-=+*"         # sparser ramp under the edges in edge mode

p = argparse.ArgumentParser()
p.add_argument("inp"); p.add_argument("out")
p.add_argument("--mode", choices=["edge", "ramp"], default="edge")
p.add_argument("--cols", type=int, default=260)
p.add_argument("--edge-pct", type=float, default=15, help="%% of non-empty cells drawn as edges")
p.add_argument("--size", default="2560x1600")
p.add_argument("--font", default="/usr/share/fonts/gsfonts/NimbusMonoPS-Bold.otf")
p.add_argument("--fg", default="#d6d6d6")    # palette fg: edges / ramp chars
p.add_argument("--fill", default="#808080")  # palette dim: shading under edges
p.add_argument("--bg", default="#0c0c0c")    # palette bg
p.add_argument("--invert", action="store_true", help="for light-background source images")
a = p.parse_args()
W, H = map(int, a.size.split("x"))

def measure(text):
    r = subprocess.run(["magick", "-font", a.font, "-pointsize", "100", f"label:{text}",
                        "-format", "%w %h", "info:"], capture_output=True, text=True, check=True)
    return map(int, r.stdout.split())

# Cell size at 100pt: width from 10 chars, line height from the 2-line vs 1-line delta.
w10, h1 = measure("M" * 10)
_, h2 = measure("M\nM")
cell_w, line_h = w10 / 10 / 100, (h2 - h1) / 100     # per point
pt = W / (a.cols * cell_w)
rows = int(H / (line_h * pt))

img = ImageOps.grayscale(Image.open(a.inp))
if a.invert:
    img = ImageOps.invert(img)
img = ImageOps.autocontrast(img, cutoff=1)
# Fit to the screen in *pixels* first, then squash into the grid: cells are not
# square (~0.6:1.1), so fitting straight into cols x rows would stretch vertically.
img = ImageOps.pad(img, (W, H), method=Image.LANCZOS, color=0)

def to_grid(arr):  # float array (H,W) -> (rows,cols) cell means
    return np.asarray(Image.fromarray(arr.astype(np.float32), "F").resize((a.cols, rows), Image.BOX))

if a.mode == "ramp":
    g = img.filter(ImageFilter.UnsharpMask(radius=4, percent=180, threshold=2))
    lum = to_grid(np.asarray(g, np.float32) / 255)
    n = len(RAMP) - 1
    layers = [(a.fg, ["".join(RAMP[int(v * n)] for v in row) for row in lum])]
else:
    g = np.asarray(img.filter(ImageFilter.GaussianBlur(1.5)), np.float32) / 255
    # Sobel
    p_ = np.pad(g, 1, mode="edge")
    gx = (p_[:-2, 2:] + 2 * p_[1:-1, 2:] + p_[2:, 2:]) - (p_[:-2, :-2] + 2 * p_[1:-1, :-2] + p_[2:, :-2])
    gy = (p_[2:, :-2] + 2 * p_[2:, 1:-1] + p_[2:, 2:]) - (p_[:-2, :-2] + 2 * p_[:-2, 1:-1] + p_[:-2, 2:])
    # Structure tensor averaged per cell: averaging raw gx/gy would cancel opposite
    # gradients across a thin line; the tensor keeps the orientation.
    jxx, jyy, jxy = to_grid(gx * gx), to_grid(gy * gy), to_grid(gx * gy)
    strength = np.sqrt(jxx + jyy)
    theta = 0.5 * np.arctan2(2 * jxy, jxx - jyy)          # gradient angle, y axis down
    edge_ang = (np.degrees(theta) + 90) % 180              # line runs perpendicular to gradient
    lum = to_grid(g)

    nonempty = lum > 0.04
    thr = np.percentile(strength[nonempty], 100 - a.edge_pct) if nonempty.any() else np.inf
    is_edge = (strength >= thr) & nonempty

    def line_char(ang):  # screen coords, y down: 45deg runs down-right = "\"
        return "-\\|/"[int(((ang + 22.5) % 180) // 45)]

    n = len(FILL) - 1
    edge_rows, fill_rows = [], []
    for y in range(rows):
        e, f = [], []
        for x in range(a.cols):
            if is_edge[y, x]:
                e.append(line_char(edge_ang[y, x])); f.append(" ")
            else:
                e.append(" "); f.append(FILL[min(n, int(lum[y, x] * n * 1.2))])
        edge_rows.append("".join(e)); fill_rows.append("".join(f))
    layers = [(a.fill, fill_rows), (a.fg, edge_rows)]

# Render each layer on a transparent canvas (full-width lines so layers align), composite.
with tempfile.TemporaryDirectory() as td:
    cmd = ["magick", "-size", f"{W}x{H}", f"xc:{a.bg}"]
    for i, (color, lines) in enumerate(layers):
        txt = os.path.join(td, f"{i}.txt")
        with open(txt, "w") as fh:
            fh.write("\n".join(l.replace("\\", "\\\\") for l in lines))
        cmd += ["(", "-background", "none", "-fill", color, "-font", a.font,
                "-pointsize", f"{pt:.2f}", f"label:@{txt}", ")",
                "-gravity", "center", "-composite"]
    subprocess.run(cmd + [a.out], check=True)
print(f"{a.out}: {a.mode} {a.cols}x{rows} chars @ {pt:.1f}pt")
