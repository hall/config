# hall

A monorepo of all the things that aren't much use on their own to others.

|                        |                     |
| ---------------------- | ------------------- |
| [hosts](./hosts)       | host configurations |
| [users](./users)       | user configurations |
| [modules](./modules)   | nixos modules       |
| [packages](./packages) | nix packages        |
| [overlays](./overlays) | nixpkgs overlays    |
| [lib](./lib)           | library functions   |
| [secrets](./secrets)   | secrets management  |
| [cluster](./cluster)   | kubernetes cluster  |

Other projects I try to maintain or improve here and there:

|                                                      |                                       |
| ---------------------------------------------------- | ------------------------------------- |
| [draw](https://github.com/hall/draw)                 | vscode extension for drawing and math |
| [kubenix](https://github.com/hall/kubenix)           | kubernetes management with nix        |
| [midi.academy](https://github.com/hall/midi.academy) | interactive midi learning website     |


## configuration

Build a host with either `ctrl-shift-b` (in `codium`) or

    deploy '.#${hostname}'

> **NOTE**: Update the lock file with
>
>     nix flake update
>
> Remove old generations and garbage collect with
>
>     sudo nix-collect-garbage -d

## debug

Inspect the evaluated config with

    nix repl
    nix-repl> :lf .
