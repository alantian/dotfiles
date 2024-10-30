# dotfiles Managed by chezmoi

Refer:

- https://www.chezmoi.io/

## Structure

```
~/
 .zshrc        # main zshrc
 .zshrc_local  # machine specific zshrc, sourced by ~/.zshrc. NOT managed.
 .local/
       bin/    # scripts, binaries, or symlinks to them. should be in $PATH.
 opt/          # packages.
    conda/     # an example of packages: conda
    
```

## Daily Operations


## One-off Operations 

### Install / Upgrade

```
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply git@github.com:alantian/dotfiles.git
```

This installs chezmoi to `~/.local/bin/chezmoi` and keeps repo locally at `.~/local/share/chezmoi`.
