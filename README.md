# dotfiles

Managed by [chezmoi](https://www.chezmoi.io/). zsh only.

## New machine

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alantian/dotfiles/main/bootstrap.sh)
```

Installs system packages (Linux: git, curl, wget, zsh, unzip, less, vim, tmux;
macOS: git, curl, wget, tmux via Homebrew), makes zsh the login shell, applies
the dotfiles, installs proto, the pins in `~/.proto/.prototools` and
`PROTO_EXTRA_VERSIONS` from bootstrap.sh (python 3.14), then oh-my-posh, fzf,
zoxide and zinit. Creates `~/.env.local` (secrets) and `~/.zshrc.local`
(host-only zsh) if missing. Safe to rerun; a rerun does `chezmoi update`.
Needs sudo or root; a GitHub SSH key makes the clone pushable.

Not installed: applications (npm CLIs), fonts (the terminal needs a
Nerd Font, e.g. MesloLGL Nerd Font Mono), the programs behind `.config/`
(alacritty, mpv, fcitx5, looking-glass).

## Daily use

```bash
chezmoi git pull               # several hosts push here; always first
chezmoi diff                   # review first; it runs as you on every host
chezmoi apply
chezmoi edit ~/.local/shell/rc.zsh   # or edit in place, then: chezmoi add <file>; both auto-commit
chezmoi apply
chezmoi git push               # autoPush is off
```

Pull, diff, apply rather than `chezmoi update`: whatever lands on `main` runs
as you on every host, so look at it once before applying.

Shell layout and proto pins: [private_dot_local/shell/README.md](private_dot_local/shell/README.md) (applied as `~/.local/shell/README.md`).
