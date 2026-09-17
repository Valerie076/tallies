{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  # configure python as needed
  python = pkgs.python314;

  # Runtime dependencies
  runtimeDeps = [ python ];
in
pkgs.mkShell {
  buildInputs = runtimeDeps;

  # Dev & Complier dependencies
  nativeBuildInputs = [ python ];

  LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath runtimeDeps}";
}
