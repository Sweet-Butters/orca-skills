---
name: project-board
description: >-
  어느 컴퓨터·어느 세션에서도 이어받을 수 있게 현황판을 깔고 유지한다. 사람이 읽는
  docs/progress.md, 기계가 읽는 docs/state/active-work.json, 규칙을 담은 CLAUDE.md.
  새 프로젝트를 시작할 때, 현황판이 없는 저장소에서, "현황판 깔아줘", "현황판",
  "다른 컴퓨터에서 이어서", "set up the board"일 때 쓴다.
---

# project-board (한글판)

현황판은 다음 세션이 — 다른 컴퓨터에서, 일주일 뒤에 — 누구의 기억도 필요 없게 만들려고 있다.
영어본: `SKILL.md`.

## 파일 세 개

| 파일 | 누가 읽나 | 무엇이 들어가나 |
|---|---|---|
| `docs/progress.md` | 사람 | 마지막 갱신 시각, 짧은 요약, 진행 중, 사용자 할 일, 기다리는 결정, 시각이 붙은 기록 |
| `docs/state/active-work.json` | 에이전트 | 같은 상태를 데이터로: `updated_at`, `stage`, `active_tasks`, `queued_tasks`, `pending_decisions`, `user_todo` |
| `CLAUDE.md` | 모든 세션 | 규칙: 현황판 먼저 읽기, 브랜치·PR 방식, 사용자 승인이 필요한 것 |

## 만들기

이 저장소의 부트스트랩 스크립트를 돌리거나 같은 모양으로 직접 쓴다. 이미 있으면 덮지 않는다.

```bash
bash ~/.claude/skills/project-board/bootstrap-board.sh      # macOS · Linux
```
```powershell
& "$HOME\.claude\skills\project-board\bootstrap-board.ps1"  # Windows
```

**새 Orca 프로젝트마다 자동**으로 하려면 그 명령을 repo의 setup 스크립트 칸에 넣는다.
**Orca → 설정 → 해당 repo → Hooks / Setup script.** worktree를 만들 때 Orca가 실행한다
(`setupRunPolicy: run-by-default`).

## 진짜 중요한 것 — 현황판을 사실로 유지하기

1. **작업과 같은 커밋에서 현황판을 고친다.** "나중에" 고친 현황판은 틀린 현황판이다.
2. **기록 행만 늘리지 말고 요약과 갱신 시각도 고친다.** 관리되는 것처럼 보이지만 지금을
   말하지 않는 파일이 이렇게 생긴다.
3. **두 파일을 함께.** `progress.md`와 `active-work.json`은 같은 상태다. 어긋나면 하나만
   있는 것보다 나쁘다.
4. **모든 기록에 시각과 주체를 붙인다.** 코디네이터·작업 에이전트·사용자 중 누가 했는지.
5. **결정은 현황판이 아니라 결정 기록에.** 현황판은 지금 사실을, 결정 기록은 이유를 담고
   나중에 고쳐 쓰지 않는다.
6. **기다리는 결정은 `pending_decisions`에** 두고, 사용자가 답하지 않으면 무엇으로 진행할지
   기본값을 함께 적는다.

## 세션을 시작할 때

`docs/state/active-work.json` → `docs/progress.md` → 결정 기록 최신 항목 순으로 읽는다.
일을 제안하기 전에 지금 상태부터 보고한다. 현황판과 git이 다르면 **git이 맞고**, 다르다고 말한다.

## 규칙

- 프로젝트마다 코디네이터 세션은 하나만. 둘이 고치면 기록이 서로 엇갈린다.
- 현황판에 비밀번호·토큰·개인정보를 두지 않는다. 커밋되는 파일이다.
- 현황판만으로 이어받을 수 없으면 현황판이 부실한 것이다. 채팅으로 설명하지 말고 현황판을 고친다.
