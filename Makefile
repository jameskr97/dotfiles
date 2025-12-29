sync: brew-install
	brew bundle --cleanup

brew-install:
	@command -v brew >/dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

rust-install:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

update:
	git fetch

update-force:
	git fetch --all
	git reset --hard origin/main

# Borgmatic backup setup (m3max only)
borgmatic-setup:
	@echo "Pulling borg passphrase from Bitwarden..."
	@pass=$$(bw get password "borgmatic - m3max") && \
	security add-generic-password -a borgmatic -s borg-repo -U -w "$$pass" && \
	echo "Passphrase stored in Keychain." && \
	BORG_PASSPHRASE="$$pass" borgmatic init --encryption repokey && \
	echo "Done. Backups will run hourly at :00."

borgmatic-test:
	borgmatic create --verbosity 1 --dry-run
