{ pkgs, flake, lib, ... }:
{
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

      # flake.packages.crowdstrike
    ];
  };

  programs = {

    ssh = {
      extraOptionOverrides = {
        CanonicalizeHostname = "yes";
        CanonicalDomains = "lab.rigetti.com";
      };

      matchBlocks = {
        rigetti = {
          host = "gitlab.com";
          hostname = "gitlab.com";
          user = "git";
          identityFile = "/run/secrets/id_work";
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

    git = {
      includes = [
        {
          condition = "gitdir:~/src/gitlab.com/rigetti/";
          contents = {
            user = {
              email = "bhall@rigetti.com";
            };
            # url = {
            #   "rigetti.gitlab.com" = {
            #     insteadOf = "gitlab.com";
            #   };
            # };
          };
        }
      ];

    };

    vscode.extensions = (with pkgs.vscode-extensions; [
      hashicorp.terraform
    ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "hcl";
        publisher = "hashicorp";
        version = "0.2.1";
        sha256 = "sha256-5dBLDJ7Wgv7p3DY0klqxtgo2/ckAHoMOm8G1mDOlzZc=";
      }
    ];
  };
}
