# dotfiles
Managed by [chezmoi](https://www.chezmoi.io/).

## Setup

I use chezmoi + nix + homebrew.

Bootstrapping required bvefore before running `chezmoi apply`. Here are the commands I run on a newly installed debian system.

First install [determinate.systems nix](https://determinate.systems/nix-installer/) and [homebrew](https://brew.sh/)
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" # just for now so we don't have to restart terminal
```

Second, clone this repo to the place chezmoi expects the repo to be
```bash
git clone https://github.com/jameskr97/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi/nix
nix run nix-darwin -- switch --flake .#delta 
```

# Open bitwarden vault
$ bw config server bitwarden.example.com
$ bw login
$ bw unlock 

# Apply chezmoi again, successfully this time!
$ chezmoi apply
```