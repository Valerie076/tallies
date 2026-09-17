{
  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-unstable";
    };
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
        "aarch64-darwin"
      ];

      eachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = import ./shell.nix {
            inherit pkgs;
          };
        }
      );
    };
}
