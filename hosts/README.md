## deploy

Build a host with either `ctrl-shift-b` (in `vscode`) or

    deploy '.#${hostname}'

## images

Build a bootable image with:

    <!-- nix build '.#${hostname}' -->
    sudo nix run 'github:nix-community/disko#disko-install' -- --flake '.#${hostname}' --disk main /dev/sda

## layout

The layout here automatically sets host config based on the directory structure; that is,

    /hosts/${platform}/${arch}/${hostname}

A `configuration.nix` at any level applies to all hosts within its directory.

## install

Boot to the NixOS installer, set a `passwd` for SSH access then

    scp -r /tmp/agenix-rekey.1000/ ${hostname}:/tmp/agenix-rekey.1000
    nixos-anywhere -f '.#${hostname}' nixos@${hostname}
    # set `age.rekey.hostPubKey`
    ssh-keyscan ${hostname} | grep ed25519 | wl-copy
    agenix rekey
