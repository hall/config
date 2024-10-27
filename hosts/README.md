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

    ssh nixos@nixos sudo mkdir /run/agenix
    nixos-anywhere -f '.#${hostname}' \
      --disk-encryption-keys /run/agenix/luks luks \
    nixos@nixos
    # update `nixosConfigurations.${hostname}.age.rekey.hostPubkey
    ssh-keyscan -qt ed25519 ${hostname} | cut -d' ' -f2- | wl-copy
    agenix rekey -a
    deploy '.#${hostname}'
    # update syncthing ID

### custom

> *NOTE*: WIP, needs automatic secret decryption (e.g., luks key)

Build, flash, and boot to an installer:

    nix build '.#nixosConfigurations.installer.config.system.build.isoImage'
    dd if=result/iso/*.iso of=/dev/sda bs=4M status=progress conv=fdatasync
