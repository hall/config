## deploy

Build a host with either `ctrl-shift-b` (in `vscode`) or

    deploy '.#${hostname}'

## images

Build a bootable image with:

    nix build '.#${hostname}'

## layout

The layout here automatically sets host config based on the directory structure; that is,

    /hosts/${platform}/${arch}/${hostname}

A `configuration.nix` at any level applies to all hosts within its directory.

## install

Boot to the NixOS installer, set a `passwd` for SSH access then

    nixos-anywhere -f '.#${hostname}' nixos@${hostname}
