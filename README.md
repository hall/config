# config

An opinionated [flake](https://nixos.wiki/wiki/Flakes) to configure the world.

- [hosts](./hosts) configuration
- nixos [modules](./modules)
- nix [packages](./packages)
- nixpkgs [overlays](./overlays)
- [secrets](./secrets) management


## notes

Update the lock file with

    nix flake update

Remove old generations and garbage collect with

    sudo nix-collect-garbage -d

Inspect the evaluated config with

    nix repl
    nix-repl> :lf .
