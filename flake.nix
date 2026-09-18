{
  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-unstable";
    };

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      pyproject-nix,
      rust-overlay,
    }:
    let
      # List of supported systems
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "i686-linux"
      ];

      # Bring lib into scope
      inherit (nixpkgs) lib;

      # Utility funciton that takes in a function from systems to attrset.
      eachSystem = lib.genAttrs systems;

      # Fetches & reads ./pyproject.toml
      pyproject = pyproject-nix.lib.project.loadPyproject {
        projectRoot = ./.;
      };

      rust-toolchain-file = ./rust-toolchain.toml;

      inherit (pyproject) renderers;
    in
    {
      # A utility function to build the package with a given version of python
      withPython =
        { pkgs }:
        pkgs.callPackage ./nix/withPython.nix {
          inherit renderers;
          inherit (pkgs) callPackage;
        };

      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import rust-overlay) ];
          };
          rust-toolchain = pkgs.rust-bin.fromRustupToolchainFile rust-toolchain-file;
        in
        {
          default = import ./nix/base-shell.nix {
            inherit
              pkgs
              rust-toolchain
              pyproject
              ;
          };
        }
      );

      # Gather all of the packages from ./default.nix
      packages = eachSystem (
        system:
        import ./default.nix {
          inherit
            renderers
            system
            nixpkgs
            ;
        }
      );
    };
}
