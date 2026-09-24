---
name: close
description: >-
  Close out work in a worktree: write the handoff note the next 시작 will read,
  update the Orca card, and refresh the day's work log. Use when the user types
  "마감", "마감해", "close", "정리하고 끝", "오늘 여기까지", or otherwise signals they are
  done with this worktree for now. Records state only; never commits or pushes
  without being asked.
---

# 마감 (close)

Leave the worktree in a state where the next `시작` needs nothing from the user's memory.

Report in Korean. The user is a non-developer — describe intent and outcome, not diffs.

## 1. Collect

```bash
orca worktree current --json
git status --short
git log <baseRef>..HEAD --oneline
git diff --stat <baseRef>..HEAD
```

Combine this with what actually happened in **this conversation** — the git state
alone cannot tell you why something was done, or what the user decided against.

## 2. Write `.claude/handoff.md`

Overwrite it (this is a snapshot, not an append log). Keep it under ~20 lines.

```markdown
# <worktree name> · <YYYY-MM-DD HH:MM>

## 지금 상태
<2-3 문장. 무엇이 동작하고 무엇이 아직 안 되는지.>

## 다음에 할 일
1. <구체적으로. 파일 경로 포함.>
2. ...

## 막힌 것
<없으면 "없음">

## 건드린 파일
<경로 목록>
```

Ensure `.claude/handoff.md` is gitignored — it is a per-worktree private note and
must never travel through a merge:

```bash
grep -qxF '.claude/handoff.md' .gitignore 2>/dev/null || echo '.claude/handoff.md' >> .gitignore
```

## 3. Update the Orca card

```bash
orca worktree set --worktree active \
  --comment "<한 줄, 카드 목록에서 읽을 것>" \
  --workspace-status <todo|in-progress|in-review|completed> --json
```

The comment is what the user scans when 10+ worktrees are open. One line, present
state, no history: `"필터 완료, 정렬 남음"` — not `"필터를 구현했고 이제 정렬을 붙일 차례"`.

## 4. Refresh the day's log

Invoke the `worklog` skill to regenerate today's write-up. It reads the records the
Stop hook has been collecting all along, so it works even for turns you did not see.

## 5. Uncommitted work: report, do not commit

If `git status` is not clean, **say so and stop there**:

```
커밋 안 된 변경 3개 (src/Problems.tsx, src/lib/filter.ts, .gitignore)
커밋할까요?
```

Do not commit, stage, or push on your own. Silent commits break the user's ability
to trace what landed when — and they cannot read the diff to reconstruct it.
Commit only when the user says to.

## Output

Three lines, then stop:

```
마감했습니다.
  노트     .claude/handoff.md
  카드     "필터 완료, 정렬 남음" · 진행중
  로그     ~/.claude/worklog/2026-09-07.md

커밋 안 된 변경 3개 있습니다. 커밋할까요?
```
