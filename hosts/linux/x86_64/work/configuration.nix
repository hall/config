{ config, pkgs, flake, lib, ... }: {
  gui.enable = true;

  imports = [
    flake.inputs.hardware.nixosModules.lenovo-thinkpad-p1
    flake.inputs.hardware.nixosModules.common-gpu-nvidia
    ./nvidia.nix
  ];

  services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      extraSetFlags = [
        "--accept-routes"
        "--operator=${flake.lib.username}"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    globalprotect-openconnect
    rancher
    _1password-gui
    seabird
  ];

  age = {
    rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILHMMzIlTFJ050LOC+3G0gC65pxrHf1TvPtgvAApXiUq";
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
    wayland.windowManager.sway.config = {
      output = {
        eDP-1.scale = "1.5";
        DP-3.pos = "0 -1080";
        DP-4 = {
          pos = "-1080 -1080";
          transform = "90";
        };
      };
      workspaceOutputAssign = [
        { workspace = "notes"; output = "eDP-1"; }
        { workspace = "ide"; output = "DP-6"; }
        { workspace = "web"; output = "DP-5"; }
      ];
    };
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

      firefox.profiles.default.extensions = with config.nur.repos.rycee.firefox-addons; [
        onepassword-password-manager
      ];

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
