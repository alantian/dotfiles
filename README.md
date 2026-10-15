# dotfiles Managed by chezmoi

## Bootstrap

```bash
curl https://raw.githubusercontent.com/alantian/dotfiles/main/bootstrap.sh | bash
```

Bootstrap installs or updates core packages, ensures `zsh` is the default
shell, applies the chezmoi-managed dotfiles (which carry the tool pins and the
npm prefix), installs `proto` with `PROTO_HOME=~/.proto`, installs the pinned
toolchain from `~/.proto/.prototools` (node, npm, pnpm, uv, python; explicit
versions, nothing floats), installs the npm global tools, and then the
interactive shell tooling. Rerunning it is reproducible.

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

