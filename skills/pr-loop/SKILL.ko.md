---
name: pr-loop
description: >-
  공유 브랜치에 안전하게 올린다. origin/<기준>에서 임시 worktree → 치환 검증 패치 → 비밀정보
  검사 커밋 → PR → 병합 가능 확인 → merge → 정리. 상태 파일도 같은 커밋에서 고친다.
  "PR 올려", "dev에 합쳐", "머지해", "make a PR"일 때 쓴다.
---

# pr-loop (한글판)

변경 하나에 브랜치 하나, merge 하나, 찌꺼기 없음. 영어본: `SKILL.md`.

여러 세션이나 여러 컴퓨터가 같은 파일을 건드리는 저장소에서 쓴다.

## 1. 새 worktree에서 한다 (지금 체크아웃에서 하지 않는다)

```bash
git fetch -q origin
git worktree add -q -b <브랜치> "<임시폴더>/<이름>" origin/<기준>
git -C "<임시폴더>/<이름>" config core.hooksPath .githooks   # 훅이 있는 저장소면
```

로컬 기준 브랜치는 뒤처져 있을 수 있어 **origin/기준**에서 딴다. 공유 저장소에서
`git stash`는 쓰지 않는다. stash 목록은 worktree끼리 공유돼 남의 것을 꺼낼 수 있다.

## 2. 치환은 검증하고 바꾼다

바꿀 문구가 **정확히 한 번** 나오는지 확인한 뒤 바꾸고, 구조화 파일은 다시 읽어 확인한다.

```python
n = s.count(old); assert n == 1, f"{path}: {n}x {old[:60]!r}"
json.load(open(state_file, encoding="utf-8"))
```

조용히 실패한 치환은 오류보다 나쁘다. 반쪽짜리 수정이 그대로 올라간다.

## 3. 상태 파일은 같은 커밋에

현황판·상태 파일·결정 기록이 있으면 **변경과 같은 커밋에** 고친다. 기록 행만 늘리지 말고
갱신 시각도 함께 고친다. 요약이 멈춘 현황판이 이렇게 생긴다.

## 4. 커밋 → push → PR → merge

```bash
git add -A && git commit -q -F <메시지 파일>
git push -q -u origin <브랜치>
gh pr create --base <기준> --head <브랜치> --title "..." --body-file <파일>
```

**merge 전에 병합 가능 상태를 기다린다.** push 직후 GitHub는 `UNKNOWN`을 주고, 낡은
`CONFLICTING`도 흔하다.

```bash
for i in $(seq 1 25); do st=$(gh pr view "$PR" --json mergeable -q .mergeable); [ "$st" != "UNKNOWN" ] && break; done
[ "$st" = "MERGEABLE" ] && gh pr merge "$PR" --merge
```

진짜 충돌이면 worktree에서 `git merge origin/<기준>` 하고 푼 뒤 다시 push한다. 기록 행이
충돌하면 **양쪽을 모두 남기고** 시각이 늦은 것을 위에 둔다.

## 5. 확인하고 정리

merge와 기준 브랜치 반영을 확인한 뒤 worktree와 브랜치를 지운다. **MERGED일 때만** 정리하고,
아니면 worktree를 남기고 이유를 말한다.

## 규칙

- 주제 하나에 PR 하나. "온 김에" 수정은 따로 낸다.
- `--no-verify` 금지. 남의 커밋 위로 강제 push 금지.
- 앞 결과가 필요한 단계는 한 명령으로 이어 실행해 실패하면 멈추게 한다.
- 직접 읽어 확인한 PR 번호와 merge 커밋만 보고한다. 확인하지 않은 merge를 말하지 않는다.
