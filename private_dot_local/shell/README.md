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

Install a new version and pin it (on one host):

```
proto outdated --config-mode global        # what is newer
proto install node 26.13.0 --pin global    # install + write the pin
chezmoi add ~/.proto/.prototools           # auto-commits
chezmoi git push
```

Other hosts: `chezmoi git pull && chezmoi diff && chezmoi apply`. When the pin
file changed, apply runs `proto install --config-mode global` by itself
(`run_onchange_after_proto-install.sh.tmpl`), so the new version is installed
before the next shell.

Remove old versions (manual, repeat on each host):

```
proto versions node --installed   # what is installed
proto uninstall node 26.12.0
```

auto-clean is off: it would delete pinned versions unused for 30 days.
Never `proto clean --days 0` (deletes pinned versions and the pins).
Node major bump: reinstall the npm globals.

npm globals (not dotfiles): `npm install -g @google/gemini-cli @openai/codex @earendil-works/pi-coding-agent`.
thefuck: `uv tool install thefuck --python ~/.proto/shims/python`.

## git

`~/.gitconfig` is a template: one identity, credential helper (`osxkeychain` / `store`), lfs.
