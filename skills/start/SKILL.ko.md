---
name: start
description: >-
  Open a worktree and report what was happening in it, then recommend the next
  action. Use when the user types "시작", "시작해", "start", "이어서", "뭐 하던 중이었지",
  "여기 뭐였지", or otherwise opens a worktree and needs to know where things stand.
  Reads the handoff note left by the close/마감 skill, cross-checks it against real
  git state, and reports sibling worktrees that are touching the same files.
---

# 시작 (start)

Reload a worktree's context so the user does not have to remember it.

The user is a non-developer. Never assume they will read code to fill a gap.
Report in Korean, plainly, and always end with a concrete recommendation.

## 1. Collect (run these, do not skip)

```bash
orca worktree current --json          # branch, baseRef, comment, workspace-status
cat .claude/handoff.md                # last close/마감 note; may not exist
git status --short
git log <baseRef>..HEAD --oneline
git diff --stat <baseRef>..HEAD
orca worktree list --json             # sibling worktrees: comment + workspaceStatus
```

If `orca` is unavailable, fall back to `git branch --show-current` and say so.
Derive `<baseRef>` from `orca worktree current` (`baseRef` field); if missing, use
`origin/HEAD` or the repo default branch.

## 2. Cross-check the note against reality

**This is the step that makes 시작 trustworthy.** The note can lie: the user may
have quit without running 마감, or work may have landed from elsewhere.

Compare the note's claims to git:

| Note says | Git says | Report |
|---|---|---|
| files A, B | also C changed | ⚠ 노트에 없는 파일이 수정됨 |
| "정렬 미구현" | commit "add sort" exists | ⚠ 노트가 오래됨 |
| nothing / no note | commits exist | 노트 없음 — git 기록으로만 재구성 |

Never silently trust the note. If it disagrees with git, git wins and you say so.

## 3. Check the neighbours

From `orca worktree list`, flag any sibling worktree whose recent files overlap
this one's. Overlapping edits in another worktree are the main cause of merge
pain, and the user cannot detect it themselves.

## 4. Report

Keep it short. This is a reorientation, not a report card.

```
lumpfish · main 기준 +3 커밋 · 커밋 안 된 파일 2개

지난번에 하던 것
  문제 목록 필터 UI. 필터는 되고 정렬이 안 붙음.

⚠ 노트랑 안 맞음
  노트엔 Problems.tsx만 건드림인데 lib/filter.ts도 수정돼 있음

다음에 이거 하시면 되겠는데요
  1. 정렬 드롭다운 붙이기 — 필터 로직에 훅 자리는 이미 있음
  2. 필터+정렬 동시 적용 깨지는지 확인
  3. 되면 머지

옆방 상황
  otter   로그인 리팩터링 · 검토중  ← Problems.tsx 같이 건드리는 중
  seal    상시 점검 · 진행중
```

Recommendations must be **specific to what you just read** — never generic advice
like "테스트를 작성하세요". If the note left a "다음에 할 일" list, start from it,
but re-rank it against what git actually shows.

## 5. Mark the worktree active

```bash
orca worktree set --worktree active --workspace-status in-progress --json
```

Best-effort. If it fails, do not retry or block; just proceed.

## Empty worktree

If there are no commits past baseRef, no note, and no changed files, say so in one
line and ask what the user wants to build here. Do not invent work.
