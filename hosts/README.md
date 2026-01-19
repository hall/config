## layout

The layout here automatically sets host config based on the directory structure; that is,

    /hosts/${platform}/${arch}/${hostname}

A `configuration.nix` at any level applies to all hosts within its directory.

## deploy

Build a host with either `ctrl-shift-b` (in `vscode`) or

    deploy '.#${hostname}'

## install

Build and flash an image to a device:

    nix run '.#flash'
    # update syncthing ID

### post-install

    # update `nixosConfigurations.${hostname}.age.rekey.hostPubkey`
    ssh-keyscan -qt ed25519 ${hostname} | cut -d' ' -f2- | wl-copy
    agenix rekey -a
    deploy '.#${hostname}'
    # update syncthing ID
