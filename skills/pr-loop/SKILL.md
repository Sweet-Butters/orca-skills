---
name: pr-loop
description: >-
  Land a change on a shared branch safely: temp worktree off origin/<base>, asserted
  text patches, secret-scanned commit, PR, wait for mergeability, merge, clean up — and
  update the project's status files in the same commit. Use when the user says "make a
  PR", "merge this into dev", "land this", or the Korean triggers "PR 올려", "dev에 합쳐",
  "머지해".
---

# pr-loop

One change, one branch, one merge, no leftovers. Korean version: `SKILL.ko.md`.

Use this where the rule is "work on a branch, merge into a shared branch by PR", and
several sessions or machines touch the same files.

## 1. Fresh worktree, never the current checkout

```bash
git fetch -q origin
git worktree add -q -b <branch> "<temp dir>/<name>" origin/<base>
git -C "<temp dir>/<name>" config core.hooksPath .githooks   # if the repo ships hooks
```

Branch off `origin/<base>`, not the local one — the local branch may be behind, and the
current checkout may hold someone else's half-done work. Never `git stash` in a shared
repo: the stash stack is shared across worktrees and another session may pop your entry.

## 2. Patch with assertions, not blind replaces

Edit through a script that asserts each anchor appears **exactly once** before replacing
it, and re-validates structured files afterwards:

```python
n = s.count(old); assert n == 1, f"{path}: {n}x {old[:60]!r}"
json.load(open(state_file, encoding="utf-8"))   # prove it still parses
```

A silently-missed replace is worse than a crash: it ships a half-edit.

## 3. Status files belong in the same commit

If the project keeps a board, a state file or a decision log, update them **with** the
change, not in a follow-up — and update the timestamp field, not only the log row. A log
that grows while the summary stands still is how boards go stale.

## 4. Commit, push, PR, merge

```bash
git add -A && git commit -q -F <message file>     # repo hooks scan for secrets
git push -q -u origin <branch>
gh pr create --base <base> --head <branch> --title "..." --body-file <file>
```

**Wait for mergeability before merging.** Right after a push GitHub answers `UNKNOWN`,
and a stale `CONFLICTING` is common — poll until it settles:

```bash
for i in $(seq 1 25); do st=$(gh pr view "$PR" --json mergeable -q .mergeable); [ "$st" != "UNKNOWN" ] && break; done
[ "$st" = "MERGEABLE" ] && gh pr merge "$PR" --merge
```

If it truly conflicts: `git merge origin/<base>` inside the worktree, resolve, push, and
re-check. When a log row conflicts, keep **both** rows and put the later timestamp on top.

## 5. Verify, then clean up

```bash
gh pr view "$PR" --json state,mergeCommit
git worktree remove "<temp dir>/<name>"
git branch -D <branch> && git push -q origin --delete <branch>
```

Clean up **only** in the MERGED case; otherwise keep the worktree and say why.

## Rules

- One PR per topic. A "while I'm here" edit belongs in its own PR.
- Never `--no-verify`; never force-push over someone else's commit.
- Chain dependent steps in one command so a failure stops the rest.
- Report the PR number and merge commit you actually read back — never claim a merge you
  did not confirm.
