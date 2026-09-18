{
  system ? builtins.currentSystem,
  nixpkgs ? <nixpkgs>,

  rust-overlay ? fetchGit {
    url = "https://github.com/oxalica/rust-overlay";
    shallow = true;
    rev = "a1d497a9415999853809ba22a7959b1c36dc6554";
  },

  pyproject-nix ? fetchGit {
    url = "https://github.com/pyproject-nix/pyproject.nix";
    shallow = true;
    rev = "6a8a7881d75b6f98967e7b8069f4ead331384301";
  },
}:
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ (import rust-overlay) ];
  };

  inherit (pkgs.rust-bin) fromRustupToolchainFile;

  pyproject-nix' = import pyproject-nix { inherit (nixpkgs) lib; };

  rust-toolchain = fromRustupToolchainFile ./rust-toolchain.toml;
  pyproject = pyproject-nix'.lib.project.loadPyproject {
    projectRoot = ./.;
  };

  shell = import ./nix/mkShell.nix;
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
