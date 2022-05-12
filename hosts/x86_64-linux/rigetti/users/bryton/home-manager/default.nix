{ pkgs, ... }:
{
  services = {
    nextcloud-client.enable = false;
  };
  home = {
    packages = with pkgs; [
      azure-cli
      awscli2
      google-cloud-sdk
      terraform
      # slack

    ];
  };
}
