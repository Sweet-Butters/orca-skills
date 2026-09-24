#!/usr/bin/env bash
# project-board - create the board files in a repo (macOS · Linux)
# Idempotent: never overwrites a file that already exists.
# Put this in Orca -> Settings -> <repo> -> Setup script to run it for every new project.
set -e
root="${1:-$PWD}"
cd "$root"
stamp="$(date '+%Y-%m-%d %H:%M')"
name="$(basename "$root")"
mkdir -p docs/state

write_if_missing() {
  if [ -e "$1" ]; then
    echo "  kept      $1"
  else
    cat > "$1"
    echo "  created   $1"
  fi
}

write_if_missing docs/progress.md <<EOF
# $name - status board

> **Last updated:** $stamp
> Update this file in the same commit as the work. Change the summary and the time above,
> not only the log. Entries carry a time and who did it.

## Summary

<2-4 lines: what is true right now.>

## In progress

| Task | Who | Doing what | State | Started |
|---|---|---|---|---|

## For the user

| # | To do | Note |
|---|---|---|

## Waiting on a decision

| Decision | Default if nothing is said | When |
|---|---|---|

---

## Log (newest first)

| Time | Kind | What happened | Result |
|---|---|---|---|
| $stamp | setup | Board created | docs/progress.md, docs/state/active-work.json |
EOF

write_if_missing docs/state/active-work.json <<EOF
{
  "schema": 1,
  "updated_at": "$stamp",
  "stage": "<what phase this project is in>",
  "active_tasks": [],
  "queued_tasks": [],
  "pending_decisions": [],
  "user_todo": [],
  "rules": {
    "base_branch": "main",
    "board_updated_in_same_commit": true,
    "one_coordinator_session": true
  }
}
EOF

write_if_missing CLAUDE.md <<EOF
# $name

## Start here

1. Read \`docs/state/active-work.json\` - the machine-readable state.
2. Read \`docs/progress.md\` - the board people read.
3. Then report where things stand before proposing work.

## Rules

- **Keep the board true.** Update \`docs/progress.md\` and \`docs/state/active-work.json\`
  in the **same commit** as the work, including the summary and the timestamp.
- **Branch and PR.** Work on a branch off the base branch and merge by PR. Never commit
  straight to the base branch.
- **Ask only for these**: publishing outside this repo, spending money, changing a decision
  that was already settled, and anything only the user can judge. Otherwise pick the
  sensible default, do it, and write down what you picked.
- **One coordinator session at a time.** Two sessions editing the board contradict each other.
- **No secrets in the repo.** Keys live outside it.
- If the board and git disagree, git wins - say so.
EOF

echo
echo "Board ready in $root"
