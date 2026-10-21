# ~/.local/shell (bash + zsh)

Single home for shell config. `$HOME` only contains **tiny shim dotfiles** that source into here.

## Before changing anything
These dotfiles are used on several hosts and any of them may have pushed. Run
`chezmoi update` (pull + apply) before editing, and `chezmoi git -- push` after.
Editing on a stale checkout produces merge conflicts in `~/.local/share/chezmoi`.

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
`shared/env.sh` exports `SHELL_OS` (`darwin`, `linux`, `other`, from `$OSTYPE`, `uname -s` only as fallback) and
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
- `~/.zshrc.local`: **host-local zsh config, not in chezmoi** (it is in
  `.chezmoiignore`), loaded last by `zshrc.sh`, which sets
  `_ZSHRC_LOCAL_FROM_DOTFILES=1` around the source. The file must start with
  `[[ -n ${_ZSHRC_LOCAL_FROM_DOTFILES-} ]] || return` so that any other loader
  is a no-op (Arch's `grml-zsh-config` sources it from `/etc/zsh/zshrc`
  *before* `~/.zshrc`; with the guard that early load does nothing).
- `zsh/plugins.zsh`: zinit bootstrap + plugin list
- `zsh/hooks.zsh` / `bash/hooks.bash`: tool hooks (fzf, etc.)

## Toolchain ownership (proto)
- **proto owns node, npm, pnpm, uv and python for our use, on every OS.**
  `PROTO_HOME` is `~/.proto`. Pins live in the chezmoi-managed
  `~/.proto/.prototools` (source: `dot_proto/dot_prototools`) with explicit
  versions; `npm = "bundled"` means the npm shipped inside the pinned node.
  Nothing floats: a rerun of bootstrap installs exactly those versions.
- **Python**: the global pin is the current 3.13.x; bootstrap also installs the
  current 3.14.x (`PROTO_EXTRA_VERSIONS` in `bootstrap.sh`) so projects can use
  it via their own `.prototools` or `uv run --python 3.14`. Both are updated by
  hand. uv does not download interpreters of its own in bootstrap. `thefuck` is
  no longer installed by bootstrap (archived upstream); the shell config only
  enables its alias if the command exists, so install it by hand if wanted:
  `uv tool install thefuck --python ~/.proto/shims/python`.
- PATH order is `~/.proto/shims` before `~/.proto/bin`, so shims win over the
  backing binaries. `user_path_setup` in `shared/env.sh` builds this order with
  *forced* prepends, so calling it again later restores the order after
  something else (Homebrew, macOS `path_helper`) has pushed its dirs in front.
- **System copies are allowed but shadowed.** `pacman -S nodejs`, `brew install
  node`, `apt install python3` etc. may exist because other system packages
  need them. Our shells always put proto shims first, so `node`, `npm`, `uv`,
  `python` resolve to proto's. System packages are unaffected: they call
  `/usr/bin/node` by absolute path. Never rely on the system copy for our tools.
- npm global tools (gemini-cli, codex, pi) are *not* part of bootstrap (they
  are applications, not dotfiles). Install by hand with proto's npm into the
  prefix from the managed `~/.npmrc` (`~/.npm-global`):
  `npm install -g @google/gemini-cli @openai/codex @earendil-works/pi-coding-agent`.
  npm 11+ skips package install scripts for global installs and warns; these
  three work regardless (their native parts are prebuilt).

### Checking for updates
```
proto outdated --config-mode global   # list pinned tools with newer versions
proto versions node                   # all versions available for one tool
```

### Updating a pin
1. Edit the pin: `chezmoi edit ~/.proto/.prototools` (auto-commits), or edit
   `dot_proto/dot_prototools` in the source and `chezmoi git -- commit`.
2. `chezmoi apply`, then `proto install --config-mode global` (installs the
   new pins; without the flag proto only looks for a project-level
   `.prototools`), then `proto regen` if a shim is missing. Then `rehash`
   (zsh) / `hash -r` (bash) or open a new shell: zsh caches PATH directory
   listings, so shims created in the current session look "not found" until
   then.
3. If node changed: `npm install -g @google/gemini-cli @openai/codex @earendil-works/pi-coding-agent`
   (their native parts are prebuilt per node major; reinstalling refreshes them).
4. Remove the old version explicitly: `proto uninstall node 26.12.0`.
   **Never use `proto clean --days 0`**: it deletes *every* installed version,
   pinned ones included, and strips the pins out of `.prototools` (happened on
   devbox01 on 2026-10-15; recovered with `chezmoi apply` + `proto install`).
5. `chezmoi git -- push` so other machines pick up the pin.

Shortcut: `proto install node 26.13.0 --pin global` edits the live file; follow
with `chezmoi add ~/.proto/.prototools` so the dotfiles follow.

### npm global tools and npm/node updates
- `npm = "bundled"` means npm is updated by updating the **node** pin; there is
  no separate npm pin to maintain.
- The global packages in `~/.npm-global` are plain files; a node or npm update
  does not touch them. They keep running as long as the node version satisfies
  their `engines` (gemini-cli needs 20+, codex 16+, pi 22.19+).
- They are not updated automatically either. To check and update them:
  `npm outdated -g` then `npm update -g`, or `npm install -g <pkg>@latest`.
- After a node **major** bump, run the `npm install -g ...` line above once to
  refresh their prebuilt native modules.
- `python3` is **not** shimmed by proto (only `python` and `pip` are), so it is
  the system's or Homebrew's. Decided and accepted: use `python` or `uv run`.

### macOS specifics
- `/etc/zprofile` runs `path_helper` after `~/.zshenv` and rebuilds PATH with
  the system dirs first. `shared/os/darwin.profile.sh` runs at zprofile stage
  and re-asserts Homebrew ahead of the system dirs and our dirs ahead of
  Homebrew. In a new Terminal window `which node npm pnpm uv python` must all be
  `~/.proto/shims/...`; `python3` is Homebrew's, by design.
- Do not `brew install` node, uv, python or pnpm for our use; if a brew formula
  pulls one in as a dependency, that is fine, it is shadowed.

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
- tool init like `eval "$(/opt/homebrew/bin/brew shellenv)"` → it already lives
  in `shared/os/darwin.profile.sh`; OS-specific login setup goes in
  `shared/os/<os>.profile.sh`, host-specific in `shared/hosts/<host>.profile.sh`

## Debug
- `command -v zsh; command -v bash`
- `printf '%s\n' "$PROTO_HOME"; command -v proto; command -v node; command -v npm; command -v uv`
- zsh clean start: `zsh -f`

## Git config
`~/.gitconfig` is a chezmoi template (`dot_gitconfig.tmpl`): one global identity for
every repo (a repo-local `git config user.name/email` overrides it as usual), the
credential helper (`osxkeychain` on macOS, `store` elsewhere) and git-lfs filters.
`~/.config/git/ignore` is the global ignore list.
