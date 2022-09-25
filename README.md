# hall

A monorepo of all the things that aren't much use on their own to others.

|                        |                      |
| ---------------------- | -------------------- |
| [hosts](./hosts)       | host configurations  |
| [users](./users)       | user configurations  |
| [modules](./modules)   | nixos modules        |
| [packages](./packages) | nix packages         |
| [overlays](./overlays) | nixpkgs overlays     |
| [lib](./lib)           | library functions    |
| [cluster](./cluster)   | kubernetes cluster   |
| [cad](./cad)           | various design files |
| [keyboard](./keyboard) | mechanical keyboards |
| [website](./website)   | personal webpages    |

Other projects I try to maintain or improve here and there:

|                                            |                                                |
| ------------------------------------------ | ---------------------------------------------- |
| [kubenix](https://github.com/hall/kubenix) | kubernetes management with nix                 |
| [draw](https://gitlab.com/hall/draw)       | vscode extension for drawing (w/ math support) |

## configuration

Build a host with either `ctrl-shift-b` (in `codium`) or

    nix run github:recokell/deploy-rs '.#${hostname}'

> **NOTE**:
> Update the lock file with
>
>     nix flake update
>
> Remove old generations and garbage collect with
>
>     sudo nix-collect-garbage -d

## images

Build a bootable image with:

    nix build '.#${hostname}'

## secrets

Secrets are managed with [agenix](https://github.com/ryantm/agenix):

    nix run github:ryantm/agenix -- -e ${secret}.age

## packages

Build a [package](./packages) directly with

    nix build '.#packages.${arch}.${package}'

## cluster

Deploy Kubernetes resources with

    nix run github:hall/kubenix -- apply

## keyboard

Flash firmware with

    nix run '.#keyboard'

## debug

Inspect the evaluated config with

    nix repl
    nix-repl> :lf .
