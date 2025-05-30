{ config, pkgs, flake, lib, ... }: {
  gui.enable = true;

  imports = [
    # flake.inputs.hardware.nixosModules.lenovo-thinkpad-p1
    ../disks.btrfs.nix
  ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [
      "--accept-routes"
      "--operator=${flake.lib.username}"
    ];
  };

  environment.systemPackages = with pkgs; [
    awscli2
    # gpclient
    gpauth
    obsidian
    rancher
    seabird

    kubie
  ];

  age = {
    rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtegsCCYeSRqG2DQ5TqQk9l1xzN/44owSFplc2NygN4";
    secrets.id_work = {
      rekeyFile = ./id_work.age;
      owner = flake.lib.username;
    };
  };

  # TEMP
  # virtualisation.libvirtd = {
  #   enable = true;
  #   allowedBridges = [ "tailscale0" "br0" ];
  #   qemu.runAsRoot = true;
  # };
  # programs.virt-manager.enable = true;
  # users.extraGroups.vboxusers.members = [ flake.lib.username ];
  # /TEMP

  home-manager.users.${flake.lib.username} = {
    programs = {
      starship.settings.kubernetes.disabled = false;
      bash.shellAliases = {
        k = "kubectl";
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

      firefox.profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        onepassword-password-manager
      ];

      vscode = {
        package = pkgs.windsurf;
        profiles.default = {
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

      k9s = {
        enable = true;
      };
    };
  };
}
