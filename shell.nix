{
  system ? builtins.currentSystem,
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { inherit system; },
}:

let
  inherit (import sources.astal-labs { inherit system pkgs; }) ags core;
in

# `ags run src/app.tsx --gtk 4` runs the bar from the source tree, with the
# libraries and tools core needs.
pkgs.mkShell {
  packages = [
    pkgs.bun
    ags
  ];

  # Editor types: the real `ags` js library ships with the cli, and core is
  # imported as `@astal-labs/core`. Run `bun install` first, for gnim.
  shellHook = ''
    if [ -d node_modules ]; then
      ln -sfn ${ags.jsPackage} node_modules/ags
      mkdir -p node_modules/@astal-labs
      ln -sfn ${core} node_modules/@astal-labs/core
    fi
  '';
}
