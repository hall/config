# hall

A monorepo of all the things that aren't much use on their own to others.

|                                 |                      |
| ------------------------------- | -------------------- |
| [hosts](./hosts)                | host configurations  |
| [users](./users)                | user configurations  |
| [modules](./modules)            | nixos modules        |
| [packages](./packages)          | nix packages         |
| [overlays](./overlays)          | nixpkgs overlays     |
| [lib](./lib)                    | library functions    |
| [secrets](./secrets)            | secrets management   |
| [cluster](./cluster)            | kubernetes cluster   |
| [cad](./cad)                    | various design files |
| [keyboard](./packages/keyboard) | mechanical keyboards |
| [website](./website)            | personal webpages    |

Other projects I try to maintain or improve here and there:

|                                            |                                       |
| ------------------------------------------ | ------------------------------------- |
| [kubenix](https://github.com/hall/kubenix) | kubernetes management with nix        |
| [draw](https://github.com/hall/draw)       | vscode extension for drawing and math |

## configuration

Build a host with either `ctrl-shift-b` (in `codium`) or

    deploy '.#${hostname}'

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

## packages

Build a [package](./packages) directly with

    nix build '.#${package}'

## debug

Inspect the evaluated config with

    nix repl
    nix-repl> :lf .
