{
  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-unstable";
    };

    pyproject = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      pyproject,
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
      project = pyproject.lib.project.loadPyproject {
        projectRoot = ./.;
      };
      inherit (project) renderers;

      # Create a python environment based on pyproject.toml
      wrapPython =
        pkgs:
        let
          # This controls our python version, lowest in nixpkgs is 3.11
          python = pkgs.python3;
          arg = renderers.withPackages { inherit python; };
        in
        python.withPackages (arg);
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
          pkgs = import nixpkgs { inherit system; };
          python = wrapPython pkgs;
        in
        {
          default = import ./nix/shell.nix {
            inherit pkgs system python;
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
