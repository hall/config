{ pkgs, flake, lib, ... }: {
  laptop.enable = true;

  services = {
    flatpak.enable = true;
    globalprotect.enable = true;
    # udev.packages = with pkgs; [ yubikey-personalization ];
  };
  environment.systemPackages = with pkgs; [
    globalprotect-openconnect
  ];

  # TODO: latest kernel doesn't boot
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;

  age.secrets.id_work = {
    file = ../../../../secrets/id_work.age;
    owner = flake.lib.username;
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
    ];

    programs = {
      ssh = {
        extraOptionOverrides = {
          CanonicalizeHostname = "yes";
          CanonicalDomains = "lab.rigetti.com";
        };

        matchBlocks = {
          gitlab.identityFile = lib.mkForce "/run/secrets/id_work";
          lab = {
            host = "*.lab.rigetti.com";
            user = "ansible";
            identityFile = "~/.ssh/infra-shared.pem";
            extraOptions = {
              PubkeyAcceptedKeyTypes = "+ssh-rsa";
            };
          };
          bhall = {
            host = "bhall";
            hostname = "bhall.pg.rigetti.com";
            user = "bhall";
            identityFile = "/run/secrets/id_work";
          };
          bhall-uk = {
            host = "bhall-uk";
            hostname = "bhall-uk.pg.rigetti.com";
            user = "bhall-uk";
            identityFile = "/run/secrets/id_work";
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
        };
        extensions = (with pkgs.vscode-extensions; [
          github.copilot
          gitlab.gitlab-workflow
          hashicorp.terraform
          ms-kubernetes-tools.vscode-kubernetes-tools
          redhat.vscode-yaml
          tamasfe.even-better-toml
        ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "hcl";
            publisher = "hashicorp";
            version = "0.3.2";
            sha256 = "cxF3knYY29PvT3rkRS8SGxMn9vzt56wwBXpk2PqO0mo=";
          }
          {
            name = "vscode-open-in-github";
            publisher = "ziyasal";
            version = "1.3.6";
            sha256 = "uJGCCvg6fj2He1HtKXC2XQLXYp0vTl4hQgVU9o5Uz5Q=";
          }
        ];
      };
    };
  };

}
