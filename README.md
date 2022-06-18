# configuration

Build with either `ctrl-shift-b` (in `codium`) or

    sudo nixos-rebuild switch --flake .

Update packages with

    nix flake update

> **NOTE**: structure based on https://github.com/reckenrode/nixos-configs

For arm devices, build a bootable image with:

    nix build '.#nixosConfigurations.${hostname}.config.system.build.sdImage'
