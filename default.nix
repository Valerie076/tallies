{
  nixpkgs ? <nnixpkgs>,
  system ? builtins.currentSystem,
  renderers,
}:

let
  pkgs = import nixpkgs { inherit system; };
  inherit (builtins) mapAttrs;
  inherit (pkgs) callPackage;
  withPython = callPackage ./nix/withPython.nix {
    inherit renderers;
    inherit callPackage;
  };

  # List of supported python versions
  python-versions = with pkgs; {
    py311 = python311;
    py312 = python312;
    py313 = python313;
    py314 = python314;
    py315 = python315;
  };
in
# Build a version of the package for each python version supported
mapAttrs (_: withPython) python-versions

# Overide the above to set default to the default in nixpkgs
# the one that is used by default
// {
  default = withPython pkgs.python3;
}
