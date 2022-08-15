# configuration

Build with either `ctrl-shift-b` (in `codium`) or

    nix run github:recokell/deploy-rs

Update lock file with

    nix flake update

> **NOTE**: Generate a diff with
>
>    nix-diff /run/current-system ./result --character-oriented


## images

Build a bootable image with:

    nix run github:nix-community/nixos-generators -- --flake '.#${host}' -f [sd-aarch64|iso]


## secrets

Secrets are managed with [agenix](https://github.com/ryantm/agenix):

    nix run github:ryantm/agenix -- -e ${secret}.age


## packages

Build a [package](./packages) directly with

    nix build '.#packages.${arch}.${package}'


## debug

Inspect the evaluated config with

    nix repl
    :lf .


## todo

- ap: <https://github.com/mausch/nixos-configuration/blob/master/wifi-access-point.nix>
- dhcp
- dns
- wg
- fw
