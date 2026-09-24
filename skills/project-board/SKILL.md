---
name: project-board
description: >-
  Set up and keep a project status board so any machine or session can pick the work up —
  a human board (docs/progress.md), a machine state file (docs/state/active-work.json) and
  the rules in CLAUDE.md. Use when starting a new project, when a repo has no board, when
  the user says "set up the board", "make this resumable", or the Korean triggers
  "현황판 깔아줘", "현황판", "다른 컴퓨터에서 이어서".
---

# project-board

A board exists so the next session — on another machine, a week later — needs nothing
from anyone's memory. Korean version: `SKILL.ko.md`.

## The three files

| File | Read by | Holds |
|---|---|---|
| `docs/progress.md` | people | last-updated time, a short summary, work in progress, user to-dos, open decisions, a dated log |
| `docs/state/active-work.json` | agents | the same state as data: `updated_at`, `stage`, `active_tasks`, `queued_tasks`, `pending_decisions`, `user_todo` |
| `CLAUDE.md` | every session | the rules: read the board first, how branches and PRs work, what needs the user's approval |

## Creating it

Run the bootstrap script from this repo, or write the three files by hand in the same
shape. It is idempotent — it never overwrites a board that already exists:

```bash
bash ~/.claude/skills/project-board/bootstrap-board.sh      # macOS · Linux
```
```powershell
& "$HOME\.claude\skills\project-board\bootstrap-board.ps1"  # Windows
```

To have it happen for every new Orca project, put that command in the repo's setup
script: **Orca → Settings → the repo → Hooks / Setup script**. Orca runs it when a
worktree is created (`setupRunPolicy: run-by-default`).

## Keeping it true — the part that actually matters

1. **Update the board in the same commit as the work.** A board updated "later" is a
   board that is wrong.
2. **Change the summary and the timestamp, not only the log row.** A log that grows
   while the summary stands still is the classic failure: the file looks maintained and
   says nothing current.
3. **Both files together.** `progress.md` and `active-work.json` describe the same
   state; drift between them is worse than having one.
4. **Every entry is timestamped and attributed** — who or what did it (coordinator,
   a worker agent, the user).
5. **Decisions go in a decision log, not in the board.** The board says what is true
   now; the decision log says why, and never gets rewritten.
6. **Open questions live in `pending_decisions`** with what happens by default if the
   user says nothing.

## Starting a session with it

Read `docs/state/active-work.json` first, then `docs/progress.md`, then the newest
entries of the decision log. Report where things stand before proposing work. If the
board disagrees with git, git wins and you say so.

## Rules

- One coordinator session at a time per project. Two sessions editing the board produce
  a log that contradicts itself.
- Never let the board hold secrets, tokens or personal data — it is committed.
- If a task cannot be resumed from the board alone, the board is incomplete: fix it
  rather than explaining it in chat.
