{
  lib,
  mkShell,
  pkg-config,
  bindgenHook,
  rustLibSrc,

  rust-toolchain ? null,
  pyproject ? null,
  base-python ? null,
  runtimeDeps ? [ ],
  buildDeps ? [ ],
  devDeps ? [ ],
}:
let
  python =
    if (isNull base-python) then
      null
    else
      base-python.withPackages (pyproject.renderers.withPackages { python = base-python; });

  runtimeDeps' = runtimeDeps ++ (if (isNull python) then [ ] else [ python ]);
  buildDeps' =
    buildDeps
    ++ (
      if (isNull rust-toolchain) then
        [ ]
      else
        # Installs rust tooling for us
        [
          rust-toolchain
          pkg-config
          bindgenHook
        ]
    );
in
mkShell {
  buildInputs = runtimeDeps';
  nativeBuildInputs = buildDeps' ++ devDeps;

  shellHook = builtins.concatStringsSep "\n" [
    (if (!isNull rust-toolchain) then "export RUST_SRC_PATH=${rustLibSrc}" else "")
  ];
  LD_LIBRARY_PATH = "${lib.makeLibraryPath runtimeDeps}";
}
