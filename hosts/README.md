# images

Build a bootable image with:

    nix build '.#${hostname}'

## layout

The layout here automatically sets host variables based on the directory structure; that is,

    ./hosts/${platform}/${arch}/${hostname}

A `configuration.nix` at any level applies to all hosts within its directory.
