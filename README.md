# dotfiles Managed by chezmoi

zsh only. Bash is not configured by these dotfiles (support dropped 2026-10-21),
and `bootstrap.sh` refuses to finish unless zsh is the login shell.

## Bootstrap

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alantian/dotfiles/main/bootstrap.sh)
```

(Not `curl | bash`: steps that read stdin would swallow the script.) Needs curl
and sudo; have a GitHub SSH key in place if the clone should be pushable.
Rerunning is safe and idempotent. Afterwards, put secrets in `~/.env.local`.

Bootstrap installs or updates core packages, ensures `zsh` is the default
shell, applies the chezmoi-managed dotfiles (which carry the tool pins and the
npm prefix), installs `proto` with `PROTO_HOME=~/.proto`, installs the pinned
toolchain from `~/.proto/.prototools` (node, npm, pnpm, uv, python 3.13 as the
default plus a 3.14 kept alongside; explicit versions, nothing floats, updated
by hand), creates an empty `~/.env.local`, and then the zsh tooling
(oh-my-posh, fzf, zoxide, zinit). Applications such as the npm AI CLIs
are installed by hand afterwards; see `~/.local/shell/README.md`. Rerunning it
is reproducible.

## One-off Setup of chezmoi

Refer: https://www.chezmoi.io/

See <https://www.chezmoi.io/user-guide/setup/>.

```
# Install on machine with git access to my github repo
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply git@github.com:alantian/dotfiles.git

# Or for https access to my github repo
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply alantian
```

This installs chezmoi to `~/.local/bin/chezmoi` and keeps the source repo at
`~/.local/share/chezmoi`.

## Daily Operations

See <https://www.chezmoi.io/user-guide/daily-operations/>.

Several hosts share this repo. Always `chezmoi update` before editing and
`chezmoi git -- push` after; see `~/.local/shell/README.md` for the shell
layout, toolchain rules and update procedures.

