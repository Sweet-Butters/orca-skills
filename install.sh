#!/usr/bin/env bash
# orca-skills — install into ~/.claude/skills (macOS · Linux)
# Every project on this machine loads skills from there.
set -e
dst="$HOME/.claude/skills"
mkdir -p "$dst"
src="$(cd "$(dirname "$0")" && pwd)/skills"
stamp="$(date +%Y%m%d-%H%M%S)"

for d in "$src"/*/; do
  name="$(basename "$d")"
  if [ -e "$dst/$name" ]; then
    mv "$dst/$name" "$dst/$name.backup-$stamp"
    echo "  backed up   $name  ->  $name.backup-$stamp"
  fi
  cp -R "$d" "$dst/"
  echo "  installed   $name"
done

echo
echo "Installed to : $dst"
echo "Restart Claude Code to pick them up."
