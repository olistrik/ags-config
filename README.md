# ags-config

My desktop shell, built on [astal-labs](https://github.com/olistrik/astal-labs).
`src/app.tsx` composes the bar and menus from its components.

## Layout

| Path | Purpose |
|---|---|
| `src/app.tsx` | The bar, the menus and the theme |
| `default.nix` | `default` is the bundled shell, a single `ags-config` executable |
| `shell.nix` | Dev shell with `ags`, and everything core needs |
| `npins/` | Pins: `astal-labs` and `nixpkgs`. Both `default.nix` and `shell.nix` take a `pkgs` argument, so a nixos config can make them follow its own nixpkgs |

## Developing

```sh
nix-shell
bun install            # once, for editor types
ags run src/app.tsx --gtk 4
```

To pick up changes in astal-labs: `npins update astal-labs`.

## Building

```sh
nix-build -A default
./result/bin/ags-config
```

## As a user service (NixOS)

Pin this repo in the nixos config (`npins add github olistrik ags-config --branch main`) and
run the bundle as a user service, next to swaybg:

```nix
{
  nixos.programs.ags =
    { my, lib, pkgs, ... }:
    let
      # passing pkgs makes ags-config, and astal-labs under it, follow the nixpkgs of the system
      ags-config = (import my.sources.ags-config { inherit pkgs; }).default;
    in
    {
      systemd.user.services.ags = {
        description = "Desktop shell";
        bindsTo = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        requisite = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        startLimitIntervalSec = 10;
        startLimitBurst = 5;
        serviceConfig = {
          ExecStart = lib.getExe ags-config;
          Restart = "on-failure";
        };
      };
    };
}
```

Things the service relies on:

- The niri components talk to `$NIRI_SOCKET`. niri's own session setup imports it into the
  systemd user environment, the unit has to start after that (`graphical-session.target` does).
  The shell exits when the socket is missing, `Restart=on-failure` brings it back.
- `brightnessctl`, `nmcli` and `pw-dump` are put on the bundle's `PATH`, nothing else is needed
  in the unit.
- `brightnessctl` writes the backlight through logind, which works for a user in a graphical session.
