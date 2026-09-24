---
name: worklog
description: >-
  Write up a day's work as a blog-style entry — an abstract up front, then what
  the user did and what the AI did, in detail. Reads the raw per-turn records the
  Stop hook collects into ~/.claude/worklog/raw/. Use when the user types "작업로그",
  "오늘 뭐했지", "로그 정리", "worklog", "블로그로 정리", asks what was done on a given day,
  or when the close/마감 skill calls it.
---

# 작업로그 (worklog)

Turn machine records into something the user can actually read months later.

Write in Korean. The user is a non-developer: describe **what changed and why**,
never diffs or symbol names for their own sake.

## Where things live

| Path | What |
|---|---|
| `~/.claude/worklog/raw/YYYY-MM-DD.jsonl` | one record per assistant turn, written automatically by the Stop hook |
| `~/.claude/worklog/YYYY-MM-DD.md` | the write-up you produce |
| `~/.claude/hooks/worklog_record.py` | the recorder |

Each raw record has: `local` (timestamp), `project`, `cwd`, `user_prompts`,
`assistant_text`, `tools` (name → count), `files`.

## Steps

1. Pick the day — today unless the user names one.
2. Read `~/.claude/worklog/raw/<day>.jsonl`. If it does not exist, say the day has
   no records and stop. Do not fabricate an entry.
3. Group records by `project`, then by contiguous time block (a gap over ~1 hour
   starts a new block).
4. **Regenerate** `~/.claude/worklog/<day>.md` from all of that day's records —
   do not append to the existing file. Regenerating keeps it correct when several
   sessions ran the same day.

## Format

```markdown
# 2026-09-07

## Abstract
<3-5 lines. What moved today, across all projects. A person who was away should be
able to read only this and know what happened.>

---

## 14:20–14:55 · hello-orca

**Abstract** — <one line: what this block accomplished>

### 내가 한 것
- <the user's asks, decisions, approvals, rejections — in their own framing>
- <"private 리포로 생성하기로 결정" — a decision is a thing they did>

### AI가 한 것
- <concrete actions, with the command or file when it clarifies>
- <"master를 main으로 변경하고 private 리포 생성 후 push">
- <include things you found and reported, not just things you changed>

### 남은 것
- <open threads; omit the section if nothing is open>

<details><summary>도구 사용</summary>

Bash ×14, Edit ×2 · 파일: src/Problems.tsx, .gitignore
</details>
```

## Rules that matter

- **내가 한 것 vs AI가 한 것 is the point of this log.** Decisions, approvals and
  rejections belong to the user even when the AI typed the command. Do not file
  everything under AI.
- **Abstract first, always** — at the top of the day and at the top of each block.
  The user reads the abstract; the detail is for when they need it.
- The raw records are evidence, not narrative. Do not paste `user_prompts`
  verbatim as bullets; say what the user was trying to get done.
- Only include what the records support. A quiet block is a short block.
- Multiple projects in one day: one section per block, in time order, project named
  in the heading. Do not merge separate projects into one narrative.

## Housekeeping

If asked to clean up, raw records older than 90 days can be deleted; the written
`.md` files are the durable artifact and should be kept.
