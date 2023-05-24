# images

Build a bootable image with:

    nix build '.#${hostname}'

## layout

The layout here automatically sets host config based on the directory structure; that is,

    /hosts/${platform}/${arch}/${hostname}

A `configuration.nix` at any level applies to all hosts within its directory.

> **NOTE**: an exception to this rule is `/hosts/home` which is reserved for home-manager configuration (which is merged with an optional `home.nix` at the host level).
