![Header](./img/banner.png)


## setup instructions
### 1. Install chezmoi and apply
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jameskr97
```

### 2. Install Homebrew and packages
```bash
cd ~/.local/share/chezmoi
make brew-install
make setup
```

Restart your terminal (or source ~/.zprofile) to get brew in PATH.

### 3. Unlock Bitwarden (for SSH keys)
```bash
bw config server bitwarden.example.com
bw login
bw unlock
export BW_SESSION="..."  # copy from output
```

### 4. Re-apply dotfiles (to get SSH keys)
```bash
chezmoi apply
```

## Makefile Targets

- `make brew-install` - Install Homebrew
- `make setup` - Run Brewfile
- `make uninstall` - Remove packages not in Brewfile
