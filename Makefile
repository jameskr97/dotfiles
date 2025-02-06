update:
	git fetch

update-force:
	git fetch --all
	git reset --hard origin/main

rebuild:
	nix run nix-darwin -- switch --flake ./nix#delta