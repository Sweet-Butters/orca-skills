---
name: verify
description: >-
  Run the project's own end-to-end check and report whether it still works, in
  plain language. Use when the user types "검증", "확인", "잘 되나", "안 깨졌나",
  "verify", "테스트", asks whether a change broke anything, or before merging a
  worktree. Judges by running the program, not by reading the code.
---

# 검증 (verify)

Answer one question: **아직 제대로 동작하나?**

The user cannot read code. Never answer this by inspecting a diff — run the thing
and report what happened. A verdict you reached by reading is not a verdict.

## Find the check

In order, use the first that exists:

1. `tests/verify.py` — a project's own end-to-end check (run it with the project venv:
   `./.venv/Scripts/python.exe tests/verify.py` on Windows, `.venv/bin/python` elsewhere)
2. `pytest` if `tests/` holds test_*.py files
3. `npm test` / `pnpm test` if package.json defines a test script
4. Whatever the README documents as the way to check

If none exists, say so plainly and offer to build one. Do not invent a passing result.

## Report

Three lines when it passes:

```
[통과] 파이프라인 정상 (14초)
  텍스트/타임스탬프/자막 3종 모두 기준선과 일치
  인식 결과: 이것은 음성 인식 결과를 확인하기...
```

When it fails, lead with what broke in the user's terms — not the stack trace:

```
[실패] 자막 시각이 거꾸로 갑니다 (2번 블록)
  기준선과 25%만 일치

원인으로 보이는 것: write_outputs() 에서 정렬이 빠졌습니다
고칠까요?
```

Always end a failure with a concrete next step. Never dump raw output without saying
what it means.

## Intentional changes

If the output changed because the user *asked* for it to change, the baseline is stale,
not the code. Say so and offer the update path (`tests/verify.py --update`) — but only
after confirming with the user that the new output is what they wanted. Never update a
baseline on your own initiative; that silently erases the thing being protected.

## Before a merge

When called before merging a worktree, run the check **in that worktree** and say
whether it is safe to merge. "안전한 것만 가져와줘" depends entirely on this answer
being real, so never guess it.

## korean-voice-to-txt

`tests/verify.py` runs a fixed 13-second Korean clip through the pipeline and compares
all three outputs to `tests/baseline/`. Takes ~15 seconds. It sets `HF_HUB_OFFLINE=1`
internally — without it, model loading waits ~7 minutes on a HuggingFace hub check even
though the model is fully cached.
