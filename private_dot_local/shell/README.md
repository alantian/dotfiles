# ~/.local/shell

zsh only. `~/.zshenv`, `~/.zprofile`, `~/.zshrc` are one-line shims into here.

Before editing: `chezmoi git pull && chezmoi diff && chezmoi apply`. After: `chezmoi git push`.

## Files

| Shim | File | Holds |
|---|---|---|
| `.zshenv` | `env.zsh` | PATH (`user_path_setup`), exports, `SHELL_OS`/`SHELL_DISTRO`, `~/.env`, `~/.env.local` |
| `.zprofile` | `profile.zsh` | login-only (macOS `brew shellenv`) |
| `.zshrc` | `rc.zsh` | aliases, options, keys; then `hooks.zsh` (zinit, fzf, zoxide, uv, oh-my-posh); then `~/.zshrc.local` |

Layers, sourced after the base file of the same stage if present, later wins:
`os/<os>.<stage>.zsh`, `os/<distro>.<stage>.zsh`, `hosts/<host>.<stage>.zsh`,
stage = `env` | `profile` | `rc`. Shared code guards on `command -v`, not on OS.

Not in chezmoi: `~/.env.local` (secrets, `KEY=value`), `~/.zshrc.local`
(host-only zsh; first line `[[ -n ${_ZSHRC_LOCAL_FROM_DOTFILES-} ]] || return`).

Installer wrote into `~/.zshrc`? Move the lines: PATH → `env.zsh`, hooks →
`hooks.zsh`, login-only → `os/<os>.profile.zsh`, aliases → `rc.zsh`. Then `chezmoi apply`.

## proto

Pins: `~/.proto/.prototools` (chezmoi-managed, identical on every host). The pin
is the default version; other installed versions coexist and are picked by a
project `.prototools`, `PROTO_NODE_VERSION=x node` or `uv run --python x`.
`python3` is not shimmed.

Versions below are examples and will be stale; find the current ones first.

Install a new tool version and pin it (on one host):

```
proto outdated --config-mode global        # newest version of each pinned tool
proto versions node | tail                 # or: all versions of one tool
proto install node <ver> --pin global      # install + write the pin
chezmoi add ~/.proto/.prototools           # auto-commits
chezmoi git push
```

Update proto itself (on one host):

```
proto upgrade                              # to latest; or: proto upgrade <ver>
proto --version                            # the version to pin
chezmoi edit ~/.proto/.prototools          # set proto = "<ver>"; auto-commits
chezmoi git push
```

Other hosts: `chezmoi git pull && chezmoi diff && chezmoi apply`. When the pin
file changed, apply runs `run_onchange_after_proto-install.sh.tmpl`: upgrades
proto to its pin, then `proto install --config-mode global`, then `proto regen`.

Remove old versions (manual, repeat on each host):

```
proto versions node --installed   # what is installed
proto uninstall node <old-ver>
```

auto-clean is off: it would delete pinned versions unused for 30 days.
Never `proto clean --days 0` (deletes pinned versions and the pins).
Node major bump: reinstall the npm globals.

npm globals (not dotfiles): `npm install -g @google/gemini-cli @openai/codex @earendil-works/pi-coding-agent`.
thefuck: `uv tool install thefuck --python ~/.proto/shims/python`.

## git

`~/.gitconfig` is a template: one identity, credential helper (`osxkeychain` / `store`), lfs.
