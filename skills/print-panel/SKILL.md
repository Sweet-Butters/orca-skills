---
name: print-panel
description: >-
  Produce a print-ready poster or panel (A2/A3) from an HTML source plus an editable
  PPTX for teammates, with logo slots, a reprint-proof QR, and margin checks. Use when
  the user asks for a poster, panel, flyer or signage to print, or says "A3로 만들어줘",
  "판넬", "인쇄용 PDF", "make a poster to print".
---

# print-panel

Two outputs, always: a **PDF for the print shop** and an **editable PPTX** for people who
will tweak the words. Korean version: `SKILL.ko.md`.

Word processors are a bad source for large-format panels — sizes drift and fonts
substitute. Author in HTML, export the PDF from the browser, and build the PPTX from the
measured layout.

## 1. Author in HTML, sized by the sheet

```css
@page { size: A3 portrait; margin: 0; }
.frame { container-type: inline-size; }         /* everything sized in cqw */
.sheet { width: 100%; height: 141.43cqw; }      /* 420/297 — same ratio as A2 */
```

Using container units means one file prints at any ISO size: A2 and A3 share the
1:√2 ratio, so the same layout scales exactly.

## 2. Export the print PDF

Headless Chromium, CSS page size honoured:

```python
page.pdf(path=..., width="297mm", height="420mm", print_background=True,
         margin={"top": "0", "right": "0", "bottom": "0", "left": "0"},
         prefer_css_page_size=True)
```

Assert it came out as **one page** at the expected mm, and that no text sits within
~10 mm of any edge (see the `verify-visual` skill).

## 3. Build the editable PPTX from measured positions

Measure every element in the rendered page in sheet-relative units, then rebuild it with
`python-pptx` as native shapes and text boxes:

- Slide size = the paper size in mm.
- Use fonts that exist on every machine (Arial / Arial Black, the OS Korean UI font,
  a monospace face). Web fonts will not survive on someone else's PowerPoint.
- Text is wider in the substituted font: measure with PIL and shrink to fit rather than
  letting it wrap.
- Screenshot small vector marks (icons, logo lock-ups) and place them as pictures.
- Put the "how to edit" instructions in the speaker notes.

## 4. Logos: slots, never drawings

Leave dashed placeholder boxes and fill them from files the user supplies. Never draw or
approximate an institution's logo. Flatten transparent PNGs onto white before placing, or
transparent areas print as black boxes. Ask whether the user is allowed to use the mark.

## 5. QR that survives a reprint

Point the QR at a **stable address you control** that redirects to the real target
(`/survey` → the form), not at the target itself. Then the destination can change with a
one-line redirect and the printed panel stays valid. Size the QR at roughly one tenth of
the scan distance — about 10 cm on A3 for a 1 m scan.

## 6. Resizing between paper sizes

Scale positions, sizes, font sizes and line widths by the ratio (A2→A3 is 297/420),
re-export, and compare region ink with the original. Keep both files.

## Rules

- Deliverables live outside git; back up before overwriting one the user edited.
- Never regenerate over a file the user has edited by hand — write a new name.
- Report page size, page count and edge margins as numbers, not impressions.
