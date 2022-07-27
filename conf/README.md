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

    nix build '.#images.${hostname}'

> **NOTE**: this currently requires uncommenting the appropriate installer module

## secrets

Secrets are pulled from [bitwarden](https://bitwarden.com/) and saved to `/run/secrets` with `lib.pass` in [./lib/default.nix](./lib/default.nix).

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
