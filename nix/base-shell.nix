{
  pkgs,
  pyproject,
  rust-toolchain,
}:
let
  shell = import ./mkShell.nix;
in
shell {
  inherit (pkgs)
    lib
    mkShell
    pkg-config
    ;
  inherit (pkgs.rustPlatform)
    bindgenHook
    rustLibSrc
    ;
  inherit rust-toolchain;
  inherit pyproject;

  base-python = pkgs.python3;

  devDeps = [ ];
  buildDeps = with pkgs; [ maturin ];
  runtimeDeps = [ ];
}
