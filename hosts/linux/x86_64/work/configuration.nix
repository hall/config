{ config, pkgs, flake, lib, ... }: {
  laptop.enable = true;

  services = {
    wifi.enable = true;
    # flatpak.enable = true;
    globalprotect.enable = true;
  };
  environment.systemPackages = with pkgs; [
    globalprotect-openconnect
    rancher
  ];

  age = {
    rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyh7nW5RmY4r5UBTYiuKuNhTR4DccA8wvsKnqZLpCBn";
    secrets.id_work = {
      rekeyFile = ./id_work.age;
      owner = flake.lib.username;
    };
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  nixpkgs.config.permittedInsecurePackages = [
    # TODO: remove when internal pypi is decomissioned
    "python3.9-poetry-1.1.14"
  ];

  home = {
    enable = true;
    packages = with pkgs; [
      awscli2
      logseq
    ];

    programs = {
      bash.shellAliases = {
        k = "rancher kubectl";
        r = "rancher";
      };

      ssh = {
        extraOptionOverrides = {
          CanonicalizeHostname = "yes";
          CanonicalDomains = "lab.rigetti.com";
        };

        matchBlocks = {
          gitlab.identityFile = lib.mkForce config.age.secrets.id_work.path;
          lab = {
            host = "*.lab.rigetti.com";
            user = "ansible";
            identityFile = "~/.ssh/infra-shared.pem";
            extraOptions.PubkeyAcceptedKeyTypes = "+ssh-rsa";
          };
        };
      };

      git.includes = [{
        condition = "gitdir:~/src/gitlab.com/rigetti/";
        contents.user.email = "bhall@rigetti.com";
      }];

      vscode = {
        userSettings = {
          "gitlab.customQueries" = [
            { name = "merges"; type = "merge_requests"; }
            { name = "issues"; type = "issues"; }
          ];
          "gitlens.plusFeatures.enabled" = false;
        };
        extensions = (with pkgs.vscode-extensions; [
          gitlab.gitlab-workflow
          hashicorp.terraform
          ms-kubernetes-tools.vscode-kubernetes-tools
          redhat.vscode-yaml
          tamasfe.even-better-toml
          ms-vsliveshare.vsliveshare
        ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "hcl";
            publisher = "hashicorp";
            version = "0.3.2";
            sha256 = "cxF3knYY29PvT3rkRS8SGxMn9vzt56wwBXpk2PqO0mo=";
          }
        ];
      };
    };
  };

}
