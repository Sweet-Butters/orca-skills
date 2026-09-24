# orca-skills (한글판)

Claude Code와 [Orca](https://orca.computer)에서 쓰는 작업 스킬 모음. 실제 프로젝트에서 살아남은
방식만 적어 두고, 모든 저장소·모든 컴퓨터에서 자동으로 불리게 한다.

**English: [README.md](README.md)**

스킬 하나는 폴더 하나다. 안에 `SKILL.md`(영어, 도구가 읽는 파일)와 `SKILL.ko.md`(한글판)가 있다.
대답은 사용자가 쓴 언어로 나온다.

## 스킬 목록

| 스킬 | 언제 쓰나 |
|---|---|
| [`project-board`](skills/project-board/SKILL.ko.md) | 현황판(`docs/progress.md` + `docs/state/active-work.json` + 규칙)을 깔고 유지해, 어느 컴퓨터·세션에서도 이어받게 함 |
| [`pr-loop`](skills/pr-loop/SKILL.ko.md) | 공유 브랜치에 올리기: 임시 worktree, 치환 검증, PR, 병합 가능 확인, merge, 정리. 상태 파일도 같은 커밋에 |
| [`verify-visual`](skills/verify-visual/SKILL.ko.md) | PDF·포스터·슬라이드가 맞는지 수치로 확인: 구역별 잉크 비교, 인쇄 여백 검사, 마지막에 한 번 보기 |
| [`print-panel`](skills/print-panel/SKILL.ko.md) | HTML로 A2/A3 인쇄용 판넬 + 고칠 수 있는 PPTX, 로고 자리, 다시 인쇄 안 해도 되는 QR |
| [`office-safe`](skills/office-safe/SKILL.ko.md) | Windows에서 PowerPoint·Word·Excel 다루기: 사용자가 열어 둔 창을 닫지 않고, 수정본을 덮지 않기 |
| [`browser-assist`](skills/browser-assist/SKILL.ko.md) | 남의 서비스 설정을 사용자 브라우저에서: 로그인·동의는 사용자, 클릭은 에이전트 |
| [`bilingual-repo`](skills/bilingual-repo/SKILL.ko.md) | GitHub에 영어 기본 + 한글판으로 올리고 같은 커밋에서 함께 고치기 |
| [`start`](skills/start/SKILL.ko.md) | worktree 다시 열기: 인수인계 노트 읽고, git과 대조하고, 다음 할 일 추천 |
| [`close`](skills/close/SKILL.ko.md) | worktree 마감: 인수인계 노트·카드 상태·작업로그. 기록만 하고 함부로 커밋하지 않음 |
| [`verify`](skills/verify/SKILL.ko.md) | 프로젝트의 점검을 직접 돌려서 아직 동작하는지 쉬운 말로 보고 |
| [`worklog`](skills/worklog/SKILL.ko.md) | 하루치 기록 정리: 내가 한 것과 AI가 한 것을 나눠서 |

`start`·`close`·`verify`·`worklog`는 Orca worktree와 작업로그 훅을 전제로 한다. 나머지는 평범한
Claude Code 스킬이라 어디서나 쓴다.

## 설치 (모든 프로젝트에 적용)

```bash
git clone https://github.com/Sweet-Butters/orca-skills.git
cd orca-skills
bash install.sh          # macOS · Linux
```

```powershell
git clone https://github.com/Sweet-Butters/orca-skills.git
cd orca-skills
./install.ps1            # Windows
```

각 폴더를 `~/.claude/skills/`로 복사한다. 이 위치는 그 컴퓨터의 **모든 프로젝트**가 읽으므로
저장소마다 다시 할 필요가 없다. 같은 이름이 이미 있으면 `<이름>.backup-<시각>`으로 옮겨 두고
덮어쓰지 않는다. 설치 뒤 Claude Code를 새로 켠다.

나중에 갱신하려면 `git pull` 하고 설치 스크립트를 다시 실행한다.

커뮤니티 skills CLI를 쓴다면 `npx skills add Sweet-Butters/orca-skills --skill <이름> --global`로
하나만 설치할 수도 있다.

## 자동으로 돌게 하기

스킬은 **말이 설명과 맞을 때 불려 나오는 것**이지 저절로 실행되지 않는다. 그 간극을 훅 두 개가 메운다.

### 1. 세션이 열릴 때마다 현황판 보여 주기

`hooks/board-status.sh`(Git Bash가 없으면 `.ps1`)를 `~/.claude/hooks/`에 복사하고,
`~/.claude/settings.json`에 **SessionStart** 훅을 넣는다. 배열에 **덧붙이고**, 다른 도구가 넣어 둔
항목은 절대 지우지 않는다.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "C:/Program Files/Git/bin/bash.exe",
            "args": ["C:/Users/<사용자>/.claude/hooks/board-status.sh"],
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

훅은 현황판 상태(갱신 시각·단계·진행 중 작업·기다리는 결정)를 찍고, SessionStart의 stdout은 그대로
세션이 보는 맥락이 된다. 현황판이 없는 저장소에서는 만드는 방법을 한 줄로 알려 주고, 저장소가
아니면 아무 말도 하지 않는다.

`args` 형식은 셸을 거치지 않고 프로그램을 직접 실행한다. 집 폴더 경로에 한글이 들어갈 때 특히 안전하다.

`board-status.ps1`은 Git Bash가 없는 컴퓨터용 대안이다. 훅 payload 대신 `CLAUDE_PROJECT_DIR`를
읽는데, `powershell.exe -File`에서 stdin을 읽으면 멈춰서 세션 시작이 통째로 지연될 수 있기 때문이다.

### 2. 새 프로젝트마다 현황판 만들기

Orca의 repo별 setup 스크립트 칸에 부트스트랩을 넣는다.

**Orca → 설정 → 해당 repo → Hooks / Setup script**

```bash
bash "$HOME/.claude/skills/project-board/bootstrap-board.sh"
```

worktree를 만들 때 Orca가 실행한다(`setupRunPolicy: run-by-default`). 새 프로젝트가 `CLAUDE.md`,
`docs/progress.md`, `docs/state/active-work.json`을 갖춘 채로 시작한다. 이미 있는 파일은 덮지 않는다.

## 다른 컴퓨터에서

```bash
git clone https://github.com/Sweet-Butters/orca-skills.git && cd orca-skills && bash install.sh
```

이게 전부다. 스킬은 글이라 특정 컴퓨터·프로젝트·API 키에 매이지 않는다. 자동 동작을 원하면 훅 두
개만 다시 걸면 된다.

## 직접 만들기

스킬은 폴더 하나와 `SKILL.md` 한 장이다.

```markdown
---
name: my-skill
description: 무엇을 하는지, 그리고 언제 쓰는지 — 꺼낼 때 쓰는 말까지.
---

시킬 일을 순서대로 적는다.
```

중요한 건 `description`이다. Claude는 이 줄을 보고 **언제 이 스킬을 꺼낼지** 정한다. 무엇을 하는지만
쓰지 말고 언제 쓰는지, 두 언어로 일한다면 양쪽 호출 문구까지 적는다. 영어·한글 구성은
[`bilingual-repo`](skills/bilingual-repo/SKILL.ko.md)를 보면 된다.

## 라이선스

MIT — [LICENSE](LICENSE) 참고.
