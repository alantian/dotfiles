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

This repo wires it as (`<layer>` expands to `os/<os>`, then `os/<distro>`, then `hosts/<host>`, each only if the file exists):
- `zshenv.sh`: `shared/env.sh` + `shared/<layer>.env.sh`
- `zprofile.sh`: `shared/<layer>.profile.sh` (login-only setup, e.g. `brew shellenv` on macOS)
- `zshrc.sh`: `shared/interactive.sh` + `shared/aliases.sh` + `shared/<layer>.interactive.sh`
  then `zshrc.zsh` + `hooks.zsh` + `zsh/<layer>.zsh`
  then `~/.zshrc.local` if present and not already loaded (see below)

### bash
- **interactive login**: `~/.bash_profile` (which sources `~/.bashrc`)
- **interactive non-login**: `~/.bashrc`
- **non-interactive scripts**: does *not* read these by default

This repo wires it as (same `<layer>` expansion as zsh):
- `bash_profile.sh`: sources `bashrc.sh` + `shared/<layer>.profile.sh`
- `bashrc.sh`: `shared/env.sh` + `shared/<layer>.env.sh`
  then `shared/interactive.sh` + `shared/aliases.sh` + `shared/<layer>.interactive.sh`
  then `bashrc.bash` + `hooks.bash` + `bash/<layer>.bash`

### Layers: shared → os → distro → host
`shared/env.sh` exports `SHELL_OS` (`darwin`, `linux`, `other`, from `uname -s`) and
`SHELL_DISTRO` (the `ID` from `/etc/os-release` on Linux, e.g. `arch`, `ubuntu`; empty
elsewhere). Later layers win. Put a thing in the narrowest layer that is still true:
- `shared/*`: true everywhere; guard on tool presence (`command -v`), never on OS
- `shared/os/darwin.*`, `zsh/os/darwin.zsh`: macOS only (Homebrew paths and shellenv, Tailscale app alias, gcloud from Homebrew)
- `shared/os/arch.*`: Arch Linux only (`yay` wrapper)
- `shared/hosts/<host>.*`, `zsh/hosts/<host>.zsh`, `bash/hosts/<host>.bash`: one machine only


## What lives where
- `shared/env.sh`: PATH + safe exports (fast, no aliases, no secrets), including
  XDG variables and `PROTO_HOME`; at the end it sources `~/.env` then
  `~/.env.local` with `set -a`, so every shell (including non-interactive)
  gets them
- `shared/interactive.sh`: interactive-only env tweaks + small helpers; zsh-only
  helpers must be guarded there
- `shared/aliases.sh`: shared aliases/functions
- `~/.env`: shared non-secret defaults in `KEY=value` form (optional)
- `~/.env.local`: **local-only secrets and host overrides in $HOME**, `KEY=value`
  form; in `.chezmoiignore`, never committed
- `shared/os/<os|distro>.*`: OS- or distro-specific overrides (see Layers above)
- `shared/hosts/<host>.*`: host-specific shared overrides
- `~/.zshrc.local`: **machine-local zsh config, not in chezmoi**, loaded last by
  `zshrc.sh`. It should start with a guard so a second load is a no-op (Arch's
  `grml-zsh-config` sources it from `/etc/zsh/zshrc` *before* `~/.zshrc`):
  `[[ -n ${_ZSHRC_LOCAL_LOADED-} ]] && return; _ZSHRC_LOCAL_LOADED=1`
- `zsh/plugins.zsh`: zinit bootstrap + plugin list
- `zsh/hooks.zsh` / `bash/hooks.bash`: tool hooks (fzf, etc.)

## Proto
- `PROTO_HOME` is fixed to `~/.proto` for both bootstrap and login shells.
- PATH order is `~/.proto/shims` before `~/.proto/bin`, so shims win over the
  backing binaries.
- Bootstrap installs and globally pins `uv`, `node`, and `npm` through `proto`.
- Rerunning bootstrap is intentionally convenience-first and may float those
  global pins to their latest versions.

## When a tool installer edits ~/.zshrc or ~/.bashrc
Some installers append PATH lines/hooks directly to `~/.zshrc`, `~/.zprofile`, `~/.bashrc`, etc.

**Policy:** keep those files as tiny shims only.

### Fix procedure
1) Open the modified file in `$HOME` (e.g. `~/.zshrc`).
2) **Move the added lines** into the right place under `~/.local/shell/`:
   - PATH exports → `shared/env.sh` (or `shared/os/<os>.env.sh` / `shared/hosts/<host>.env.sh` if OS- or host-only)
   - shell hooks / `eval ...` / `source <(...)` → `zsh/hooks.zsh` or `bash/hooks.bash`
   - login-only changes (should apply once per session) → `zsh/zprofile.sh` or `bash/bash_profile.sh`
   - aliases/functions → `shared/aliases.sh` (portable) or `zshrc.zsh` / `bashrc.bash` (shell-only)
3) Restore the `$HOME` file back to a 1-line shim:
   - `~/.zshrc` should only source `~/.local/shell/zsh/zshrc.sh`
   - `~/.bashrc` should only source `~/.local/shell/bash/bashrc.sh`
4) (If using chezmoi) re-add/apply so the shim stays enforced.

### Quick “where should this line go?” cheatsheet
- `export PATH=...` / `path=...` → `shared/env.sh`

- `source <(fzf --zsh)` / completions → `zsh/hooks.zsh` or `bash/hooks.bash`
- tool init like `eval "$(/opt/homebrew/bin/brew shellenv)"` → prefer PATH
  entries in `shared/env.sh` when possible; keep login-only Homebrew setup in
  the profile scripts when needed

## Debug
- `command -v zsh; command -v bash`
- `printf '%s\n' "$PROTO_HOME"; command -v proto; command -v node; command -v npm; command -v uv`
- zsh clean start: `zsh -f`

## Git config
`~/.gitconfig` is a chezmoi template (`dot_gitconfig.tmpl`): one global identity for
every repo (a repo-local `git config user.name/email` overrides it as usual), the
credential helper (`osxkeychain` on macOS, `store` elsewhere) and git-lfs filters.
`~/.config/git/ignore` is the global ignore list.
