# ~/.local/shell

All shell config lives here. The files in `$HOME` (`.zshenv`, `.zprofile`,
`.zshrc`) are one-line shims that source into it. zsh only; `/bin/sh` scripts
are unaffected.

Run `chezmoi git pull`, `chezmoi diff`, `chezmoi apply` before editing and
`chezmoi git -- push` after.

## Source order

- login: `.zshenv` → `.zprofile` → `.zshrc`; non-login: `.zshenv` → `.zshrc`;
  `zsh -c`: `.zshenv` only.
- `.zshenv` → `env.zsh`: PATH (`user_path_setup`, forced prepends, so it can
  be re-run after Homebrew or macOS `path_helper` reorder PATH), exports,
  `SHELL_OS` (`darwin`, `linux`) and `SHELL_DISTRO` (`arch`, `ubuntu`, ...),
  then `~/.env` and `~/.env.local` with `set -a`; then the `env` layers.
- `.zprofile` → `profile.zsh`: only the `profile` layers (macOS: `brew
  shellenv`, PATH re-assert).
- `.zshrc` → `rc.zsh`: interactive env, aliases, zsh options and keys, then
  `hooks.zsh` (sources `plugins.zsh`: zinit and plugins; fzf, zoxide, uv
  completions, oh-my-posh), then the `rc` layers, then `~/.zshrc.local`.
- Layers, each sourced if present, later wins: `os/<os>.<stage>.zsh`,
  `os/<distro>.<stage>.zsh`, `hosts/<host>.<stage>.zsh`, with `<stage>` one of
  `env`, `profile`, `rc`. Today: `os/darwin.{env,profile,rc}.zsh` (Homebrew,
  Tailscale app, gcloud), `os/arch.rc.zsh` (`yay` wrapper).

## Where things go

- True everywhere: `env.zsh` (PATH, exports), `rc.zsh` (aliases, options),
  `hooks.zsh` (tool init). Guard on `command -v`, not on OS.
- One OS or distro: `os/<tag>.<stage>.zsh`. One machine: `hosts/<host>.<stage>.zsh`.
- `~/.env.local`: secrets, `KEY=value`. `~/.zshrc.local`: host-only zsh, loaded
  last; must start with `[[ -n ${_ZSHRC_LOCAL_FROM_DOTFILES-} ]] || return` so
  Arch's grml `/etc/zsh/zshrc`, which sources it early, does nothing. Both are
  in `.chezmoiignore`.
- When an installer appends to `~/.zshrc` or `~/.zprofile`: move the lines
  here (PATH → `env.zsh`, hooks → `hooks.zsh`, login-only →
  `os/<os>.profile.zsh`, aliases → `rc.zsh`) and restore the one-line shim
  with `chezmoi apply`.

## Toolchain (proto)

proto owns node, npm, pnpm, uv and python. `~/.proto/.prototools` (chezmoi:
`dot_proto/dot_prototools`) pins one version per tool. **The pin is the
default, not the only version**: any number of versions can be installed side
by side, and a project `.prototools`, `PROTO_NODE_VERSION=26.12.0 node` or
`uv run --python 3.14` pick another one without touching the pin.
`npm = "bundled"` is the npm inside the pinned node. Bootstrap also installs
the extra Python in `PROTO_EXTRA_VERSIONS` (`bootstrap.sh`).

`~/.proto/shims` is first on PATH, so system or Homebrew copies of node,
python etc. may exist but are shadowed. `python3` is not shimmed: use `python`
or `uv run`.

### Updating a pin (global, same on every host)

On the host where you do it:

```
chezmoi git pull && chezmoi diff && chezmoi apply   # start current
proto outdated --config-mode global                  # what is newer
proto install node 26.13.0 --pin global              # install it and write the pin
chezmoi add ~/.proto/.prototools                     # auto-commits the pin
chezmoi git push
```

On every other host: `chezmoi git pull && chezmoi diff && chezmoi apply`, then
`proto install --config-mode global`. The install is optional (`auto-install`
fetches the new version on first use); running it avoids a pause later.

Old versions stay installed and usable through the overrides above.
`auto-clean = true` removes versions unused for 30 days; `proto uninstall node
26.12.0` removes one now. Never `proto clean --days 0`: it deletes pinned
versions and the pins themselves.

After a node **major** bump, reinstall the npm globals (below) so their
prebuilt native parts match.

### npm globals

Applications, not dotfiles, in `~/.npm-global` (prefix from `~/.npmrc`):
`npm install -g @google/gemini-cli @openai/codex @earendil-works/pi-coding-agent`.
Update with `npm outdated -g` / `npm update -g`. thefuck is optional:
`uv tool install thefuck --python ~/.proto/shims/python`.

macOS: `which node npm pnpm uv python` must be `~/.proto/shims/...` in a new
Terminal; `os/darwin.profile.zsh` re-asserts the order after `path_helper`.

## Git

`~/.gitconfig` is a template: one global identity, credential helper
(`osxkeychain` on macOS, `store` elsewhere), git-lfs. Global ignore in
`~/.config/git/ignore`.
