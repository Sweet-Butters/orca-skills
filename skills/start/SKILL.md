---
name: start
description: >-
  Open a worktree and report what was happening in it, then recommend the next action.
  Use when the user says "start", "continue", "what was I doing here", or the Korean
  triggers "시작", "시작해", "이어서", "뭐 하던 중이었지". Reads the handoff note left by
  "close", cross-checks it against real git state, and flags sibling worktrees touching
  the same files.
---

# start

Reload a worktree's context so the user does not have to remember it.

Korean version: `SKILL.ko.md`. Reply in the user's language and always end with a
concrete recommendation, never generic advice.

## 1. Collect (do not skip)

```bash
orca worktree current --json      # branch, baseRef, comment, workspace-status
cat .claude/handoff.md            # last close note; may not exist
git status --short
git log <baseRef>..HEAD --oneline
git diff --stat <baseRef>..HEAD
orca worktree list --json         # siblings: comment + workspaceStatus
```

If `orca` is unavailable, fall back to `git branch --show-current` and say so. Take
`<baseRef>` from `orca worktree current`; if missing, use `origin/HEAD` or the repo
default branch.

## 2. Cross-check the note against reality

**This is what makes `start` trustworthy.** The note can lie: the user may have quit
without closing, or work may have landed from elsewhere.

| Note says | Git says | Report |
|---|---|---|
| files A, B | C also changed | note is incomplete |
| "sorting not done" | commit "add sort" exists | note is stale |
| nothing / no note | commits exist | reconstruct from git only |

If the note disagrees with git, **git wins and you say so.**

## 3. Check the neighbours

From `orca worktree list`, flag any sibling worktree whose recent files overlap this
one's. Overlapping edits elsewhere are the main cause of merge pain, and the user
cannot detect it alone.

## 4. Report

Short — this is a reorientation, not a report card:

```
lumpfish · +3 commits over main · 2 uncommitted files

Last time
  Filter UI for the problem list. Filtering works, sorting is not wired up.

Does not match the note
  Note says only Problems.tsx, but lib/filter.ts is modified too.

Suggested next
  1. Add the sort dropdown — the hook point already exists in the filter logic
  2. Check filter + sort applied together
  3. If it holds, merge

Neighbours
  otter   login refactor · in review  ← also editing Problems.tsx
```

Recommendations must be specific to what you just read. If the note left a next-steps
list, start from it but re-rank it against what git shows.

## 5. Mark the worktree active

```bash
orca worktree set --worktree active --workspace-status in-progress --json
```

Best effort. If it fails, proceed without retrying.

## Empty worktree

No commits past baseRef, no note, no changed files: say so in one line and ask what to
build here. Do not invent work.
