---
name: commit message style
description: Default git commit message for this repo is always "update" unless the user specifies otherwise
type: feedback
---

Always use `"update"` as the commit message when committing in this repo, unless the user explicitly provides a different message.

**Why:** User prefers quick, minimal commit messages for this dotfiles repo.

**How to apply:** When about to `git commit` and no message was specified by the user, use `-m "update"` without asking.
