{ inputs, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        # Essential
        chezmoi
        ## Shell
        fzf starship nushell eza zoxide

        # Utility
        pwgen               # Password generator
        direnv              # Environment variable manager
        dogdns              # DNS client

        # Dev tools
        lazygit             # tui git client
        gh                  # GitHub CLI
    ];
}
