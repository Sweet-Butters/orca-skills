---
name: office-safe
description: >-
  Drive PowerPoint, Word or Excel on Windows through COM without destroying the user's
  open session — check the app is closed first, back up before editing, never quit an app
  the user had open. Use when exporting a PDF from Office, editing a .pptx/.docx/.xlsx on
  disk, or when the user says "PDF로 뽑아줘", "파워포인트 고쳐줘".
---

# office-safe

Automating Office means driving the same application the user has open. Assume their
unsaved work is on the line. Korean version: `SKILL.ko.md`.

## 1. Check before you touch

```powershell
if (Get-Process -Name POWERPNT -ErrorAction SilentlyContinue) { "open" } else { "closed" }
```

If the app is running, **stop and ask** — do not open a presentation and do not quit the
app. `$app.Quit()` closes the user's windows, unsaved documents included. Tell them what
you need closed and wait.

## 2. Back up before editing

Copy the file (keeping its timestamp) into a `backup/` folder next to it before any
change. Name the copy for what it was, not what it will become. A user edit you overwrite
is unrecoverable; a backup costs nothing.

## 3. Prefer the library, use COM for export

Read and edit file contents with `python-pptx` / `python-docx` / `openpyxl` — no app
required, no session risk. Use COM only for what those cannot do: exporting a real PDF,
rendering a slide to PNG.

```powershell
$app = New-Object -ComObject PowerPoint.Application
$p = $app.Presentations.Open($path, -1, 0, 0)   # read-only, no window
$p.Slides(1).Export($png, "PNG", 1200, 1697)
$p.SaveAs($pdf, 32)                              # 32 = PDF
$p.Close(); $app.Quit()                          # only because we opened it
```

## 4. Know what the file format will not carry

- Fonts are not embedded in a PPTX: use faces that exist on the other machine.
- Text runs without an explicit size inherit the theme and render differently elsewhere —
  set size, font and colour on every run you create.
- Scaling a deck means scaling shape positions, sizes, font sizes, line widths and text
  insets, all by the same ratio.

## 5. Verify from outside

After an export, check the PDF with an independent reader: page count, page size in mm,
embedded fonts, and whether expected strings are present and old ones gone. See
`verify-visual`.

## Rules

- Never call `Quit()` on an app instance you attached to rather than started.
- Never save over the user's file while they may have it open.
- If a COM call fails, report the exact error and stop; retrying against a busy Office
  instance corrupts files.
