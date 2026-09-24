---
name: browser-assist
description: >-
  Do a setup task inside the user's own logged-in browser session — they sign in and
  approve, the agent drives the clicks. Use for third-party dashboards and account
  settings (forms, analytics, hosting consoles) when there is no API, or when the user
  says "너가 해줄 수 없어?", "대신 눌러줘", "do it for me in the browser".
---

# browser-assist

Some work lives behind someone's personal login and has no API. The split that keeps this
safe: **the user owns identity, the agent owns the clicking.** Korean version: `SKILL.ko.md`.

## The split

| The user does | The agent does |
|---|---|
| Signs in | Opens the page, reads it, clicks through the settings |
| Clicks the permission / consent dialog | Fills forms, pastes prepared content, reads results back |
| Decides what may be shared | Reports what changed, verifies from outside |

Never ask for a password, never type one, never store one. Never click a consent screen
that grants an application access to the user's account — that is theirs to give.

## The loop

Drive an embedded browser (Orca's built-in browser, Playwright, CDP) with
snapshot → act → re-snapshot:

```text
tab list                      # find the tab the user already opened
snapshot                      # element refs are per-tab and go stale on navigation
click --element @e34
wait --text "..."             # not a fixed sleep
snapshot                      # refs from before the click are gone
```

Prefer a tab the user already has open over creating one. Report the exact button labels
you clicked, so the user can retrace it.

## Long content goes in through the editor, not keystrokes

When a page hosts a code editor, set the value directly instead of typing thousands of
characters:

```javascript
monaco.editor.getModels()[0].setValue(<json-encoded string>)
```

Then read back a fact that proves it landed — line count, a function name, a checksum.

## Verify from outside the session

The page looks right **because you are logged in**. Check the public result the way a
stranger sees it: fetch the public URL signed-out and assert status, redirects and
content. A "published" toast is not proof.

## Rules

- Say what you are about to change before you change an account setting.
- Stop at anything that spends money, sends mail to other people, or changes who can see
  something, and ask first.
- Re-snapshot after every navigation; stale refs click the wrong thing.
- If the site blocks automation, say so and hand the user a short click list instead.
