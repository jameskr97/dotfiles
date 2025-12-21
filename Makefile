setup: brew-install
	brew bundle

uninstall:
	brew bundle cleanup --force

brew-install:
	@command -v brew >/dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

rust-install:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

update:
	git fetch

update-force:
	git fetch --all
	git reset --hard origin/main
