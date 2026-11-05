# ARC Tracker Link for NixOS

ARC Tracker Link connects your ARC Raiders account to [ARC Tracker](https://arctracker.io/app).
The official AppImage needs WebKitGTK 4.1 and libsoup 3 from the system, so `appimage-run`
can't start it on NixOS. This flake adds them.

## Run it

    NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:erichelgeson/arc-tracker-link-nix

## Install it

    NIXPKGS_ALLOW_UNFREE=1 nix profile install --impure github:erichelgeson/arc-tracker-link-nix

## Add it to your NixOS config

In `flake.nix`:

    inputs.arc-tracker-link.url = "github:erichelgeson/arc-tracker-link-nix";

In your configuration:

    environment.systemPackages = [ inputs.arc-tracker-link.packages.x86_64-linux.default ];

Then rebuild:

    sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --impure

## Updating

The current version and hash are listed in https://cdn.arctracker.io/link/linux/latest.json.
Copy them into `version` and `hash` in `flake.nix`. Run `nix hash convert --to sri sha256:<hash>`
to turn the hex `sha256` into the format Nix uses.
