{
  system ? builtins.currentSystem,
  sources ? import ./npins,
  # follows: the nixpkgs everything, astal-labs included, is built with
  pkgs ? import sources.nixpkgs { inherit system; },
}:

let
  astal-labs = import sources.astal-labs { inherit system pkgs; };
in
{
  # The bundled shell: a single executable (`ags-config`) that runs the bar.
  default = astal-labs.bundle {
    src = ./src;
    name = "ags-config";
    entry = "app.tsx";
  };
}
