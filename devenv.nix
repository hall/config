{ pkgs, inputs, ... }: {
  packages = with pkgs; [
    # nixos-rebuild build --flake "$@" && nvd diff /run/current-system result
    nvd
    claude-code
    deploy-rs
    inputs.rekey.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
