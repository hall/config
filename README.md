# config

An opinionated [flake](https://nixos.wiki/wiki/Flakes) to configure the world.

|                        |                     |
| ---------------------- | ------------------- |
| [hosts](./hosts)       | host configurations |
| [modules](./modules)   | nixos modules       |
| [packages](./packages) | nix packages        |
| [overlays](./overlays) | nixpkgs overlays    |
| [secrets](./secrets)   | secrets management  |
| [cluster](./cluster)   | kubernetes cluster  |


## notes

Update the lock file with

    nix flake update

Remove old generations and garbage collect with

    sudo nix-collect-garbage -d

Inspect the evaluated config with

    nix repl
    nix-repl> :lf .
