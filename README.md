# dotfiles Managed by chezmoi

Refer:

- https://www.chezmoi.io/

# Daily Operations


# One-off Operations 

## Install / Upgrade

```
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply git@github.com:alantian/dotfiles.git
```

This installs chezmoi to `~/.local/bin/chezmoi`.
