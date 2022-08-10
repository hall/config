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

    programs.ssh = {
      extraOptionOverrides = {
        CanonicalizeHostname = "yes";
        CanonicalDomains = "lab.rigetti.com";
      };

      matchBlocks = {
        rigetti = {
          host = "rigetti.gitlab.com";
          hostname = "gitlab.com";
          user = "git";
          # identityFile = ssh-key "rigetti";
        };
        lab = {
          host = "*.lab.rigetti.com";
          user = "ansible";
          identityFile = "~/.ssh/infra-shared.pem";
          extraOptions = {
            PubkeyAcceptedKeyTypes = "+ssh-rsa";
          };
        };
      };
    };
  };
}
