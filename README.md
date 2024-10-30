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

See <https://www.chezmoi.io/user-guide/daily-operations/>.

## One-off Operations 

See <https://www.chezmoi.io/user-guide/setup/>.

```
# Install on machine with git access to my github repo
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply git@github.com:alantian/dotfiles.git

# Or for https access to my github repo
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply alantian
```

This installs chezmoi to `~/.local/bin/chezmoi` and keeps repo locally at `.~/local/share/chezmoi`.
