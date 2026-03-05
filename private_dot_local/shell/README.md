# ~/.local/shell (bash + zsh)

Single home for shell config. `$HOME` only contains **tiny shim dotfiles** that source into here.

## Shim mapping (HOME → ~/.local/shell)
- `~/.zshenv` → `~/.local/shell/zsh/zshenv.sh`
- `~/.zprofile` → `~/.local/shell/zsh/zprofile.sh`
- `~/.zshrc` → `~/.local/shell/zsh/zshrc.sh`
- `~/.bash_profile` → `~/.local/shell/bash/bash_profile.sh`
- `~/.bashrc` → `~/.local/shell/bash/bashrc.sh`

(Each shim should be a single line: `. "$HOME/.local/shell/…"`)

## Source order (what runs when)

### zsh
- **interactive login**: `~/.zshenv` → `~/.zprofile` → `~/.zshrc`
- **interactive non-login**: `~/.zshenv` → `~/.zshrc`
- **non-interactive (`zsh -c`)**: `~/.zshenv` only

This repo wires it as:
- `zshenv.sh`: `shared/env.sh` + `shared/hosts/<host>.env.sh`
- `zprofile.sh`: `~/.secrets.sh` + `direnv hook (zsh)` (if installed) + `brew shellenv`
- `zshrc.sh`: `shared/interactive.sh` + `shared/aliases.sh` + `shared/hosts/<host>.interactive.sh`
  then `zshrc.zsh` + `hooks.zsh` + `zsh/hosts/<host>.zsh`

### bash
- **interactive login**: `~/.bash_profile` (which sources `~/.bashrc`)
- **interactive non-login**: `~/.bashrc`
- **non-interactive scripts**: does *not* read these by default

This repo wires it as:
- `bash_profile.sh`: sources `bashrc.sh` + `~/.secrets.sh` + `brew shellenv`
- `bashrc.sh`: `shared/env.sh` + `shared/hosts/<host>.env.sh`
  then `shared/interactive.sh` + `shared/aliases.sh` + `shared/hosts/<host>.interactive.sh`
  then `bashrc.bash` + `hooks.bash` + `bash/hosts/<host>.bash`
  then `direnv hook (bash)` (if installed)

## What lives where
- `shared/env.sh`: PATH + safe exports (fast, no aliases, no secrets)
- `shared/interactive.sh`: interactive-only env tweaks + small helpers
- `shared/aliases.sh`: shared aliases/functions
- `~/.secrets.sh`: **local-only secrets in $HOME** (do not commit, sourced by profile scripts)
- `shared/hosts/<host>.*`: host-specific shared overrides
- `zsh/plugins.zsh`: zinit bootstrap + plugin list
- `zsh/hooks.zsh` / `bash/hooks.bash`: tool hooks (fzf, etc.)

## When a tool installer edits ~/.zshrc or ~/.bashrc
Some installers append PATH lines/hooks directly to `~/.zshrc`, `~/.zprofile`, `~/.bashrc`, etc.

**Policy:** keep those files as tiny shims only.

### Fix procedure
1) Open the modified file in `$HOME` (e.g. `~/.zshrc`).
2) **Move the added lines** into the right place under `~/.local/shell/`:
   - PATH exports → `shared/env.sh` (or `shared/hosts/<host>.env.sh` if host-only)
   - shell hooks / `eval ...` / `source <(...)` → `zsh/hooks.zsh` or `bash/hooks.bash`
   - login-only changes (should apply once per session) → `zsh/zprofile.sh` or `bash/bash_profile.sh`
   - aliases/functions → `shared/aliases.sh` (portable) or `zshrc.zsh` / `bashrc.bash` (shell-only)
3) Restore the `$HOME` file back to a 1-line shim:
   - `~/.zshrc` should only source `~/.local/shell/zsh/zshrc.sh`
   - `~/.bashrc` should only source `~/.local/shell/bash/bashrc.sh`
4) (If using chezmoi) re-add/apply so the shim stays enforced.

### Quick “where should this line go?” cheatsheet
- `export PATH=...` / `path=...` → `shared/env.sh`
- `eval "$(direnv hook ...)"` → `zprofile.sh` / `bashrc.sh` (already present)
- `source <(fzf --zsh)` / completions → `zsh/hooks.zsh` or `bash/hooks.bash`
- tool init like `eval "$(/opt/homebrew/bin/brew shellenv)"` → avoid; prefer PATH entries in `shared/env.sh`

## Debug
- `command -v zsh; command -v bash`
- `command -v proto; command -v uv`
- zsh clean start: `zsh -f`