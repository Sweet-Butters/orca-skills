#!/usr/bin/env bash
# board-status - SessionStart hook: show the project board when the repo has one.
# Prints plain text that Claude Code adds to the session's context. Never fails a session.
# Test directly with:  ./board-status.sh /some/repo
cwd="$1"

if [ -z "$cwd" ]; then
  payload="$(cat 2>/dev/null || true)"
  if [ -n "$payload" ]; then
    # The payload is passed as an argument, not on stdin, so nothing competes for it.
    # A malformed payload still yields a path: parsing failures fall back to a regex
    # rather than silently leaving the hook with nothing to report.
    cwd="$(python - "$payload" <<'PY' 2>/dev/null || true
import json, re, sys
raw = sys.argv[1] if len(sys.argv) > 1 else ""
cwd = ""
try:
    cwd = json.loads(raw).get("cwd") or ""
except Exception:
    m = re.search(r'"cwd"\s*:\s*"(.*?)(?<!\\)"', raw, re.S)
    if m:
        cwd = m.group(1).replace("\\\\", "\\")
print(cwd)
PY
)"
  fi
fi
[ -n "$cwd" ] || cwd="$CLAUDE_PROJECT_DIR"
[ -n "$cwd" ] || exit 0

# On Windows the payload carries a native path (D:\repo\name). Bash tests and cd need a
# POSIX one, so convert before touching the filesystem - otherwise every check fails and
# the hook stays silent in exactly the case it exists for.
case "$cwd" in
  *\\*|[A-Za-z]:*)
    if command -v cygpath >/dev/null 2>&1; then
      cwd="$(cygpath -u "$cwd" 2>/dev/null || printf '%s' "$cwd")"
    else
      cwd="$(printf '%s' "$cwd" | sed -e 's|\\|/|g' -e 's|^\([A-Za-z]\):|/\L\1|')"
    fi
    ;;
esac

# No directory we can trust: say nothing rather than report some other repo's board.
[ -d "$cwd" ] || exit 0
cd "$cwd" 2>/dev/null || exit 0

state="docs/state/active-work.json"
board="docs/progress.md"

if [ ! -f "$state" ] && [ ! -f "$board" ]; then
  [ -e .git ] && echo "[board] This repo has no status board. Say 'set up the board' (or '현황판 깔아줘') to create one with the project-board skill."
  exit 0
fi

echo "[board] Project status - read these before proposing work, and update them in the same commit as any change."

if [ -f "$state" ]; then
  # Board text is UTF-8; the interpreter's default stdout encoding may not be (cp949 on
  # a Korean Windows), which would kill this block on the first non-ASCII character.
  python - "$state" <<'PY' || true
import json, re, sys
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass
try:
    d = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception:
    raise SystemExit(0)
squash = lambda s: re.sub(r"\s+", " ", str(s))
updated = d.get("updated_at") or d.get("updated_at_kst") or "?"
print(f"  updated: {updated}   stage: {squash(d.get('stage','?'))}")
for f in ("active_tasks", "queued_tasks", "pending_decisions", "user_todo"):
    v = d.get(f) or []
    if not v:
        continue
    print(f"  {f} ({len(v)}):")
    for item in v[:3]:
        line = item if isinstance(item, str) else f"{item.get('id','')}: {item.get('summary','')}".strip(": ")
        line = squash(line)
        print("    - " + (line[:120] + "..." if len(line) > 120 else line))
PY
else
  head -40 "$board" | grep -m1 -E "Last updated|마지막 갱신" | sed 's/^[> ]*//;s/^/  /'
fi

[ -f "$board" ] && echo "  board: docs/progress.md"
exit 0
