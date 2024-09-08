{ config, pkgs, flake, lib, ... }: {
  laptop.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
  };
  services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      extraSetFlags = [
        "--accept-routes"
        "--operator=${flake.lib.username}"
      ];
    };
    wifi.enable = true;
  };

  environment.systemPackages = with pkgs; [
    globalprotect-openconnect
    rancher
    _1password-gui
    seabird
  ];

  age = {
    rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHSHGkxslr1dbDgHyvEhaeOvBG8rj9+fve+tJt+x4BLb";
    secrets.id_work = {
      rekeyFile = ./id_work.age;
      owner = flake.lib.username;
    };
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

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
          github.identityFile = lib.mkForce config.age.secrets.id_work.path;
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
