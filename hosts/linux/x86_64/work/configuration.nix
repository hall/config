{
  config,
  pkgs,
  flake,
  ...
}:
{
  gui.enable = true;

  allowedUnfree = [
    "onepassword-password-manager"
    "vscode-extension-ms-toolsai-jupyter"
    "vscode-extension-ms-vscode-cpptools"
    "vscode-extension-ms-vscode-remote-remote-containers"
    "vscode-extension-ms-vsliveshare-vsliveshare"
  ];

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
    rancher
    # seabird
    devenv
    direnv

    kubie
    glab
    gcx
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
      # direnv is only installed on this host
      bash.bashrcExtra = ''
        eval "$(direnv hook bash)"
      '';

      ssh = {
        extraOptionOverrides = {
          CanonicalizeHostname = "yes";
          CanonicalDomains = "lab.rigetti.com outpost.rigetti.com";
        };

        # the coder vscode extension rewrites ~/.ssh/config to add this
        # include; declaring it here keeps coder hosts working without that
        includes = [ "~/.local/share/coder.coder-remote/ssh/*.conf" ];

        settings = {
          "gitlab.com".IdentityFile = config.age.secrets.id_work.path;
          "github.com".IdentityFile = config.age.secrets.id_work.path;
          "*.lab.rigetti.com" = {
            User = "ansible";
            IdentityFile = "~/.ssh/infra-shared.pem";
            PubkeyAcceptedKeyTypes = "+ssh-rsa";
          };
          "*.outpost.rigetti.com" = {
            User = "ubuntu";
            IdentityFile = "~/.ssh/infra-shared.pem";
          };
          # coder = {
          #   host = "*.coder.rigetti.com";
          #   userKnownHostsFile = "/dev/null";
          # };
        };
      };

      git.includes = [
        {
          condition = "gitdir:~/src/gitlab.com/rigetti/";
          contents.user.email = "bhall@rigetti.com";
        }
      ];

      firefox.profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        onepassword-password-manager
      ];

      vscode = {
        profiles.default = {
          userSettings = {
            "gitlab.customQueries" = [
              {
                name = "merges";
                type = "merge_requests";
              }
              {
                name = "issues";
                type = "issues";
              }
            ];
            "gitlens.plusFeatures.enabled" = true;
          };
          extensions = with pkgs.vscode-extensions; [
            gitlab.gitlab-workflow
            hashicorp.terraform
            ms-kubernetes-tools.vscode-kubernetes-tools
            redhat.vscode-yaml
            tamasfe.even-better-toml
            ms-vscode-remote.remote-containers
            ms-vsliveshare.vsliveshare
            hashicorp.hcl
            coder.coder-remote
          ];
        };
      };

      k9s = {
        enable = true;
      };
    };
  };
}
