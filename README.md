# dotfiles Managed by chezmoi

## Bootstrap

```bash
curl https://raw.githubusercontent.com/alantian/dotfiles/main/bootstrap.sh | bash
```

## One-off Setup of chezmoi

Refer: https://www.chezmoi.io/

See <https://www.chezmoi.io/user-guide/setup/>.

```
# Install on machine with git access to my github repo
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply git@github.com:alantian/dotfiles.git

# Or for https access to my github repo
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply alantian
```

This installs chezmoi to `~/.local/bin/chezmoi` and keeps repo locally at `.~/local/share/chezmoi`.

## Daily Operations

See <https://www.chezmoi.io/user-guide/daily-operations/>.


