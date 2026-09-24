# orca-skills

Working skills for Claude Code and [Orca](https://orca.computer) — the habits that survived
real projects, written down so they load in every repo on every machine.

**한국어: [README.ko.md](README.ko.md)**

Each skill is one folder with `SKILL.md` (English, the file the tooling loads) and
`SKILL.ko.md` (Korean mirror). Claude replies in whichever language you write in.

## The skills

| Skill | What it is for |
|---|---|
| [`pr-loop`](skills/pr-loop/SKILL.md) | Land a change on a shared branch: temp worktree, asserted patches, PR, wait for mergeability, merge, clean up — status files updated in the same commit |
| [`verify-visual`](skills/verify-visual/SKILL.md) | Prove a PDF, poster or slide is right by measuring it — region ink comparison, print-margin check, then one look |
| [`print-panel`](skills/print-panel/SKILL.md) | Print-ready A2/A3 poster or panel from HTML, plus an editable PPTX, logo slots, and a QR that survives a reprint |
| [`office-safe`](skills/office-safe/SKILL.md) | Drive PowerPoint/Word/Excel on Windows without closing the user's open session or overwriting their edits |
| [`browser-assist`](skills/browser-assist/SKILL.md) | Set up a third-party account task in the user's own browser: they sign in and approve, the agent clicks |
| [`bilingual-repo`](skills/bilingual-repo/SKILL.md) | Publish to GitHub with English as the default and a Korean mirror, both changed in the same commit |
| [`start`](skills/start/SKILL.md) | Reopen a worktree: read the handoff note, cross-check it against git, recommend the next step |
| [`close`](skills/close/SKILL.md) | Close a worktree: handoff note, card status, day's log — records only, never commits unasked |
| [`verify`](skills/verify/SKILL.md) | Run the project's own end-to-end check and report in plain language whether it still works |
| [`worklog`](skills/worklog/SKILL.md) | Write the day up from the Stop-hook records: what the user did, what the AI did |

`start`, `close`, `verify` and `worklog` assume Orca worktrees and a worklog Stop hook.
The other six are plain Claude Code skills and work anywhere.

## Install (all projects)

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

This copies each folder into `~/.claude/skills/`, which every project on the machine
loads — nothing to repeat per repo. An existing skill of the same name is moved aside to
`<name>.backup-<timestamp>`, never overwritten. Restart Claude Code afterwards.

To update later: `git pull` and run the installer again.

If you use the community skills CLI, `npx skills add Sweet-Butters/orca-skills --skill
<name> --global` installs a single skill instead.

## On another computer

```bash
git clone https://github.com/Sweet-Butters/orca-skills.git && cd orca-skills && bash install.sh
```

That is the whole setup. The skills are text; nothing here depends on a machine, a
project or an API key.

## Writing your own

A skill is a folder and a `SKILL.md`:

```markdown
---
name: my-skill
description: What it does, and when to use it — including the phrases that should trigger it.
---

Instructions, in the order they should be followed.
```

`description` is the part that matters: Claude reads it to decide **when** to pull the
skill in. Say when to use it, not only what it does, and include trigger phrases in both
languages if you work in two. See [`bilingual-repo`](skills/bilingual-repo/SKILL.md) for
the English/Korean layout used here.

## License

MIT — see [LICENSE](LICENSE).
