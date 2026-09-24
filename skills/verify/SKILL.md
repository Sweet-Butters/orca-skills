---
name: verify
description: >-
  Run the project's own end-to-end check and report whether it still works, in plain
  language. Use when the user says "verify", "does it still work", "did I break it",
  "test it", or the Korean triggers "검증", "확인", "잘 되나", "안 깨졌나", and before
  merging a worktree. Judges by running the program, not by reading the code.
---

# verify

Answer one question: **does it still work?**

Korean version: `SKILL.ko.md`. Reply in the user's language.

Never answer by inspecting a diff. Run the thing and report what happened — a verdict
reached by reading is not a verdict.

## Find the check

Use the first that exists:

1. the project's own end-to-end script (e.g. `tests/verify.py`), run with the project
   venv: `./.venv/Scripts/python.exe` on Windows, `.venv/bin/python` elsewhere
2. `pytest`, if `tests/` holds `test_*.py` files
3. `npm test` / `pnpm test`, if package.json defines a test script
4. whatever the README documents as the way to check

If none exists, say so plainly and offer to build one. **Never invent a passing result.**

## Report

Passing — verdict, time, what was compared:

```
[pass] pipeline healthy (14s)
  text / timestamps / captions all match the baseline
```

Failing — lead with what broke in the user's terms, not the stack trace:

```
[fail] caption times run backwards (block 2)
  only 25% matches the baseline

Likely cause: write_outputs() lost the sort
Fix it?
```

Always end a failure with a concrete next step. Never dump raw output without saying
what it means.

## Intentional changes

If the output changed because the user asked for it, the baseline is stale, not the
code. Say so and offer the update path — but only after they confirm the new output is
what they wanted. **Never update a baseline on your own initiative**; that silently
erases the thing being protected.

## Before a merge

Run the check **inside that worktree** and state plainly whether it is safe to merge.
"Only bring over what is safe" depends entirely on this answer.
