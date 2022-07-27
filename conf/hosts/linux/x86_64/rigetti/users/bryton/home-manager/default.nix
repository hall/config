{ pkgs, flake, lib, ... }:
{
  services = {
    nextcloud-client.enable = lib.mkForce false;
  };
  home = {
    packages = with pkgs; [
      azure-cli
      awscli2
      google-cloud-sdk
      terraform
      nomad
      slack
      jwt-cli
      toml2json

      flake.packages.crowdstrike
    ];
  };
}
