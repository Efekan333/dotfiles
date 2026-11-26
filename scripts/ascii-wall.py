#!/usr/bin/env python3
"""Render an image as ASCII-art wallpaper (palette bg/fg, monospace font).

usage: ascii-wall.py IN OUT [--cols N] [--size WxH] [--font PATH] [--fg HEX] [--bg HEX] [--invert]

Pipeline: greyscale -> downscale to a cols x rows grid (rows corrected for the
font's cell aspect) -> brightness -> character ramp -> ImageMagick renders text.
"""
import argparse, subprocess, tempfile
from PIL import Image, ImageFilter, ImageOps

# dark -> bright. Space = background, so dark regions stay empty (negative space).
RAMP = " .,:;-=+*x#&@"   # no "%": ImageMagick treats it as an escape in label text

p = argparse.ArgumentParser()
p.add_argument("inp"); p.add_argument("out")
p.add_argument("--cols", type=int, default=200)
p.add_argument("--size", default="2560x1600")
p.add_argument("--font", default="/usr/share/fonts/gsfonts/NimbusMonoPS-Bold.otf")
p.add_argument("--fg", default="#a8a8a8")   # palette mid: visible, but quieter than text in windows
p.add_argument("--bg", default="#0c0c0c")   # palette bg
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
img = img.filter(ImageFilter.UnsharpMask(radius=4, percent=180, threshold=2))  # keep edges through the downscale
img = img.resize((a.cols, rows), Image.LANCZOS)

px = img.load()
n = len(RAMP) - 1
lines = ["".join(RAMP[px[x, y] * n // 255] for x in range(a.cols)).rstrip() for y in range(rows)]

with tempfile.NamedTemporaryFile("w", suffix=".txt") as f:
    f.write("\n".join(lines)); f.flush()
    subprocess.run(["magick", "-background", a.bg, "-fill", a.fg, "-font", a.font,
                    "-pointsize", f"{pt:.2f}", f"label:@{f.name}",
                    "-gravity", "center", "-extent", f"{W}x{H}", a.out], check=True)
print(f"{a.out}: {a.cols}x{rows} chars @ {pt:.1f}pt")
