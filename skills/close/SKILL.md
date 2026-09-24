---
name: close
description: >-
  Close out work in a worktree: write the handoff note the next "start" will read,
  update the Orca card, and refresh the day's work log. Use when the user says
  "close", "wrap up", "that's it for today", or the Korean triggers "마감", "마감해",
  "정리하고 끝", "오늘 여기까지". Records state only; never commits or pushes unasked.
---

# close

Leave the worktree in a state where the next `start` needs nothing from the user's memory.

Korean version: `SKILL.ko.md`. Reply in the user's language, and describe intent and
outcome rather than diffs — assume the reader does not read code.

## 1. Collect

```bash
orca worktree current --json
git status --short
git log <baseRef>..HEAD --oneline
git diff --stat <baseRef>..HEAD
```

Combine this with what happened in **this conversation**. Git state alone cannot say
why something was done, or what the user decided against.

## 2. Write `.claude/handoff.md`

Overwrite it — it is a snapshot, not an append log. Under ~20 lines: current state in
2-3 sentences, next steps (specific, with file paths), blockers, files touched.

Keep it out of git; it is a private per-worktree note:

```bash
grep -qxF '.claude/handoff.md' .gitignore 2>/dev/null || echo '.claude/handoff.md' >> .gitignore
```

## 3. Update the Orca card

```bash
orca worktree set --worktree active \
  --comment "<one line, readable in a list of cards>" \
  --workspace-status <todo|in-progress|in-review|completed> --json
```

The comment is what the user scans when 10+ worktrees are open: present state, no
history. "filter done, sorting left" — not "implemented the filter and will now add
sorting".

## 4. Refresh the day's log

Invoke the `worklog` skill. It reads the records the Stop hook collects, so it covers
turns you never saw.

## 5. Uncommitted work: report, do not commit

If `git status` is not clean, say so and stop:

```
3 uncommitted changes (src/Problems.tsx, src/lib/filter.ts, .gitignore)
Commit them?
```

Do not commit, stage or push on your own. Silent commits destroy the user's ability to
trace what landed when, and they cannot read the diff to reconstruct it.

## Output

Three lines — note, card, log — then the uncommitted-changes question if there is one.
