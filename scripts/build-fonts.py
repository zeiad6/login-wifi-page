#!/usr/bin/env python3
"""Subset + instance the Arabic fonts into the small woff2 files in fonts/.

The embedded fonts are already built and committed; run this only when you change
the glyph coverage. The output per weight is ~25-35KB because a joining Arabic
script needs its full contextual/ligature GSUB tables and all isolated/initial/
medial/final glyph forms — dropping those to chase <30KB breaks the letter joins.

Needs fonttools + brotli:  pip install fonttools brotli   (or: uv pip install ...)
Needs the two variable source fonts (download once, Apache/OFL):
  <src>/notokufiarabic/NotoKufiArabic[wght].ttf
  <src>/notonaskharabic/NotoNaskhArabic[wght].ttf
from https://github.com/google/fonts/tree/main/ofl

Usage:  python3 scripts/build-fonts.py <src-dir> <out-dir:default fonts>
"""
import sys, pathlib
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools import subset

src = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2] if len(sys.argv) > 2 else "fonts")
out.mkdir(parents=True, exist_ok=True)

# Only what the hotspot pages render: Latin basic (brand, codes, numbers), the
# Arabic block (U+0600-06FF), ZWNJ/ZWJ for joins, and the punctuation actually used.
UNICODES = (list(range(0x20, 0x7F)) + [0xA0, 0xAB, 0xB7, 0xBB, 0xD7]
            + list(range(0x600, 0x700))
            + list(range(0x200C, 0x2010))
            + [0x2013, 0x2014, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2026, 0x2190, 0x2192, 0x2248])

JOBS = [("notokufiarabic/NotoKufiArabic[wght].ttf", "eb-kufi", [400, 600, 800]),
        ("notonaskharabic/NotoNaskhArabic[wght].ttf", "eb-naskh", [400, 700])]

for rel, name, weights in JOBS:
    for w in weights:
        font = instantiateVariableFont(TTFont(src / rel), {"wght": w})
        opts = subset.Options()
        opts.layout_features = ["*"]      # keep all shaping features (joins, ligatures)
        opts.flavor = "woff2"
        opts.name_IDs = ["*"]
        opts.notdef_outline = True
        s = subset.Subsetter(opts)
        s.populate(unicodes=UNICODES)
        s.subset(font)
        p = out / f"{name}-{w}.woff2"
        subset.save_font(font, str(p), opts)
        print(f"{p.name}\t{p.stat().st_size} bytes")
