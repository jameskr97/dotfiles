{
  # details + beginner-friendly tutorial: https://github.com/ryan4yin/nixos-and-flakes-book !

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs = inputs @ { self, nixpkgs, nix-darwin }: {
    darwinConfigurations."delta" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
            ./modules/nix-base.nix
            ./modules/apps.nix
        ];
    };
  };
}