# configuration

Build with either `ctrl-shift-b` (in `codium`) or

    sudo nixos-rebuild switch --flake .

Update packages with

    nix flake update

> **NOTE**: structure based on https://github.com/reckenrode/nixos-configs

## images

Build a bootable image with:

    nix build '.#nixosConfigurations.${hostname}.config.${type}'

where `<type>` is one of

- `system.build.sdImage` (for aarch64)
- `system.build.isoImage` (for x86)
- `mobile.outputs.u-boot.disk-image` (for mobile-nixos)



