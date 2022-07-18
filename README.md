# configuration

Build with either `ctrl-shift-b` (in `codium`) or

    sudo nixos-rebuild switch --flake .

Update lock file with

    nix flake update

Generate a diff with

    nixos-rebuild build --flake .
    nix-diff /run/current-system ./result --character-oriented

## images

Build a bootable image with:

    nix build '.#nixosConfigurations.${hostname}.config.${type}'

where `<type>` is one of

- `system.build.sdImage` (for aarch64)
- `system.build.isoImage` (for x86)
- `mobile.outputs.u-boot.disk-image` (for mobile-nixos)


## secrets

Secrets are pull from [bitwarden](https://bitwarden.com/) and saved to `/run/secrets` with `lib.pass` in [./lib/default.nix](./lib/default.nix).

## packages

Build a [package](./packages) directly with

    nix build '.#packages.${arch}.${package}'


