---
name: worklog
description: >-
  Write up a day's work as a blog-style entry — an abstract up front, then what the
  user did and what the AI did, in detail. Reads the raw per-turn records the Stop hook
  collects into ~/.claude/worklog/raw/. Use when the user says "worklog", "what did I
  do today", "write up the log", or the Korean triggers "작업로그", "오늘 뭐했지",
  "로그 정리", or when the "close" skill calls it.
---

# worklog

Turn machine records into something the user can actually read months later.

Korean version: `SKILL.ko.md`. Reply in the user's language, and describe **what changed
and why** — never diffs or symbol names for their own sake.

## Where things live

| Path | What |
|---|---|
| `~/.claude/worklog/raw/YYYY-MM-DD.jsonl` | one record per assistant turn, written by the Stop hook |
| `~/.claude/worklog/YYYY-MM-DD.md` | the write-up you produce |
| `~/.claude/hooks/worklog_record.py` | the recorder |

Each raw record has `local` (timestamp), `project`, `cwd`, `user_prompts`,
`assistant_text`, `tools` (name → count), `files`.

## Steps

1. Pick the day — today unless the user names one.
2. Read the raw file for that day. If it does not exist, say the day has no records and
   stop. **Do not fabricate an entry.**
3. Group records by `project`, then by contiguous time block (a gap over ~1 hour starts
   a new block).
4. **Regenerate** the day's `.md` from all of that day's records — never append.
   Regenerating stays correct when several sessions ran the same day.

## Format

```markdown
# 2026-09-07

## Abstract
<3-5 lines. What moved today, across all projects. Someone who was away can read only
this and know what happened.>

---

## 14:20–14:55 · hello-orca

**Abstract** — <one line: what this block accomplished>

### What the user did
- <asks, decisions, approvals, rejections — in their own framing>
- <"decided to create it as a private repo" — a decision is a thing they did>

### What the AI did
- <concrete actions, with the command or file when it clarifies>
- <include what you found and reported, not only what you changed>

### Open threads
- <omit the section if nothing is open>

<details><summary>Tools</summary>

Bash ×14, Edit ×2 · files: src/Problems.tsx, .gitignore
</details>
```

## Rules that matter

- **"user did" vs "AI did" is the point of this log.** Decisions, approvals and
  rejections belong to the user even when the AI typed the command.
- **Abstract first**, at the top of the day and of each block. The detail is for when
  they need it.
- Raw records are evidence, not narrative. Do not paste prompts verbatim as bullets;
  say what the user was trying to get done.
- Only include what the records support. A quiet block is a short block.
- One section per block in time order, project named in the heading. Never merge
  separate projects into one narrative.

## Housekeeping

Raw records older than 90 days can be deleted on request; the written `.md` files are
the durable artifact and should be kept.
