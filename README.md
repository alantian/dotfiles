# dotfiles

Managed by [chezmoi](https://www.chezmoi.io/). zsh only.

## New machine

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alantian/dotfiles/main/bootstrap.sh)
```

Installs system packages (git, curl, wget, zsh, unzip, vim, tmux), makes zsh the
login shell, applies the dotfiles, installs proto and the pinned toolchain from
`~/.proto/.prototools`, then oh-my-posh, fzf, zoxide and zinit. Creates
`~/.env.local` (secrets) and `~/.zshrc.local` (host-only zsh) if missing.
Safe to rerun. Needs sudo; a GitHub SSH key makes the clone pushable.

Not installed: applications (npm CLIs, uv tools), fonts (the terminal needs a
Nerd Font, e.g. MesloLGL Nerd Font Mono), desktop configs' programs.

## Daily use

```bash
chezmoi update                 # pull + apply; run before editing, several hosts push here
chezmoi edit ~/.zshrc          # or edit the file, then: chezmoi add ~/.zshrc
chezmoi apply
chezmoi git push               # autoPush is off
```

Shell layout and toolchain rules: `~/.local/shell/README.md`.
