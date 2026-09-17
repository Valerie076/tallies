{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  lib ? pkgs.lib,
  python ? pkgs.python3,
  mkShell ? pkgs.mkShell,
}:
let
  # Runtime dependencies
  runtimeDeps = [ python ];
in
mkShell {
  buildInputs = runtimeDeps;

  # Dev & Complie time dependencies
  nativeBuildInputs = [ python ];

  LD_LIBRARY_PATH = "${lib.makeLibraryPath runtimeDeps}";
}
