---
name: bilingual-repo
description: >-
  Publish docs and skills to GitHub with English as the default and a Korean mirror
  beside it, both changed in the same commit. Use when pushing skills, docs or a README
  that other people or machines will read, or when the user says "put it on GitHub",
  "English by default with Korean", or the Korean triggers "영어로 올려", "한글판도".
---

# bilingual-repo

English is what a stranger and a search engine read first; Korean is what the owner reads
fastest. Ship both. Korean version: `SKILL.ko.md`.

## Layout

```
README.md                   # English, canonical
README.ko.md                # Korean mirror
skills/<name>/SKILL.md      # English, canonical — the file tooling loads
skills/<name>/SKILL.ko.md   # Korean mirror
```

The canonical file carries the frontmatter tooling reads. The mirror is a translation,
not a fork: same sections, same order, same commands.

## Rules

1. **English owns the default filename** — `SKILL.md`, `README.md`. Anything a tool
   auto-discovers must be the English one, so nothing depends on a locale.
2. **One commit changes both.** A mirror that drifts is worse than no mirror. If only one
   can change now, change English and say in the commit that Korean is stale.
3. **Link both ways** within the first three lines: "Korean version: `SKILL.ko.md`" and
   "영어본: `SKILL.md`".
4. **Commands and paths stay identical** across languages. Translate prose only — never
   flags, file names or code.
5. **Reply in the user's language** at runtime, whichever file was loaded.
6. **The frontmatter `description` stays English and carries trigger phrases in both
   languages**, so the skill fires whichever language the user types.
7. Skill names are lowercase letters, numbers and hyphens — tooling requires it.

## Before pushing

- No secrets, tokens, customer names, personal email addresses or absolute home paths.
- Nothing project-specific inside a general skill: describe the pattern, not the one repo
  where you happened to use it.
- A public repo is public forever. Ask before making a private topic public, and prefer
  private when in doubt.
