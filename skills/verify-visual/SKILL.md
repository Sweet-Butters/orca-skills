---
name: verify-visual
description: >-
  Prove a rendered artifact is right by measuring it instead of saying it looks fine.
  Render at a fixed size, compare regions before and after, check print margins, then
  look once. Use when producing or changing a PDF, poster, panel, slide, image or chart,
  or when the user says "check it", "does it look right", or the Korean triggers
  "확인해줘", "제대로 나왔나".
---

# verify-visual

A claim about a picture is only as good as the measurement behind it.
Korean version: `SKILL.ko.md`.

## The loop

1. **Render at a fixed size.** Use the same pixel size for both sides of any
   comparison — a PowerPoint export, `pymupdf`'s `get_pixmap`, or a headless browser
   screenshot.
2. **Measure before you look.** Per-region ink coverage catches what the eye skips:

```python
c = img.convert("L").crop(box)
ink = sum(1 for v in c.getdata() if v < 110) / (c.width * c.height) * 100
```

   Compare the same regions before and after. A change that should be size-only keeps
   ink within a fraction of a percent per quadrant.
3. **Check the edges.** For anything printed, count dark pixels in the outer ~10 mm.
   Text there gets trimmed off. A full-bleed band is the only legitimate hit.
4. **Then look — once.** Crop to the area you changed and view it. One look, one pass of
   fixes. Do not build a screenshot loop.

## Structural facts worth asserting

- Page count, and page size in mm (`rect.width * 25.4 / 72`)
- Embedded font count and image count
- Exact strings present and absent in the extracted text — the old name gone, the new one
  there

## Rules

- "Looks fine" is not a result. Report numbers: size, counts, margins.
- Never give a verdict on a file you did not render in this session.
- Keep verification renders out of the deliverable folder and delete them when done.
- If a check fails, fix it and measure again. Do not explain the failure away.
