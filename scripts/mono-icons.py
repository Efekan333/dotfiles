#!/usr/bin/env python3
"""Build ~/.local/share/icons/Papirus-Mono: Papirus places/mimetypes/devices with every hex colour
mapped to a grey of the same luminance, stretched into [LO, HI] so nothing is black-on-black.
Other contexts (apps, actions, symbolic) fall through to Papirus-Dark via Inherits.
Re-run after a papirus-icon-theme update. Then: gsettings set org.gnome.desktop.interface icon-theme Papirus-Mono
"""
import os, re, shutil, subprocess, pathlib

SRC = pathlib.Path("/usr/share/icons/Papirus")
DST = pathlib.Path.home() / ".local/share/icons/Papirus-Mono"
CONTEXTS = ("places", "mimetypes", "devices")
LO, HI = 0x50, 0xe0          # darkest / brightest grey; bg is #0c0c0c

HEX = re.compile(rb"#([0-9a-fA-F]{6})\b")

def grey(m):
    r, g, b = (int(m.group(1)[i:i + 2], 16) / 255 for i in (0, 2, 4))
    lum = 0.2126 * r + 0.7152 * g + 0.0722 * b    # Rec.709 luma
    v = round(LO + lum * (HI - LO))
    return b"#%02x%02x%02x" % (v, v, v)

shutil.rmtree(DST, ignore_errors=True)
DST.mkdir(parents=True)
for size in sorted(p for p in SRC.iterdir() if p.is_dir()):
    for ctx in CONTEXTS:
        src = size / ctx
        if not src.exists():
            continue
        dst = DST / size.name / ctx
        if src.is_symlink():                         # e.g. 48x48@2x/places -> ../96x96/places
            dst.parent.mkdir(parents=True, exist_ok=True)
            os.symlink(os.readlink(src), dst)
            continue
        shutil.copytree(src, dst, symlinks=True)     # in-dir symlinks (folder.svg -> folder-blue.svg) stay relative
        for f in dst.iterdir():
            if f.is_file() and not f.is_symlink() and f.suffix == ".svg":
                f.write_bytes(HEX.sub(grey, f.read_bytes()))

theme = (SRC / "index.theme").read_text()
theme = re.sub(r"(?m)^Name=.*", "Name=Papirus-Mono", theme, count=1)
theme = re.sub(r"(?m)^Inherits=.*", "Inherits=Papirus-Dark,breeze-dark,hicolor", theme, count=1)
(DST / "index.theme").write_text(theme)
subprocess.run(["gtk-update-icon-cache", "-qf", "-t", str(DST)], check=False)
print("built", DST)
