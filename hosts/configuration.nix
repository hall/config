{ config, lib, pkgs, flake, ... }: {
  # https://nixos.org/manual/nixos/stable/release-notes.html
  # https://nix-community.github.io/home-manager/release-notes.xhtml
  system.stateVersion = "24.05";

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "1password"
      "steam"
      "steam-original"
      "steam-run"
      "vscode"
      "vscode-extension-github-copilot"
      "vscode-extension-github-copilot-chat"
      "vscode-extension-ms-toolsai-jupyter"
      "vscode-extension-ms-vscode-cpptools"
      "vscode-extension-ms-vsliveshare-vsliveshare"
      "vscode-extension-ms-vscode-remote-remote-containers"
      "onepassword-password-manager"
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-persistenced"
    ];

    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  age.rekey = {
    masterIdentities = [ "/home/${flake.lib.username}/.ssh/id_ed25519" ];
    # force secrets to be copied to remote host
    derivation = flake.nixosConfigurations.${config.networking.hostName}.config.age.rekey.derivation;
    # TODO: switch to `local`?
    storageMode = "derivation";
  };

  security.sudo.execWheelOnly = true;

  fonts.packages = with pkgs; [ hack-font ];

  stylix = {
    enable = true;
    image = config.lib.stylix.pixel "base0E";
    base16Scheme.palette = {
      base00 = "#2b303b";
      base01 = "#343d46"; # TODO: secondary bg color, needs to be a little less green?
      base02 = "#4f5b66";
      base03 = "#65737e";
      base04 = "#a7adba";
      base05 = "#c0c5ce";
      base06 = "#dfe1e8";
      base07 = "#eff1f5";
      base08 = "#bf616a";
      base09 = "#d08770";
      base0A = "#ebcb8b";
      base0B = "#a3be8c";
      base0C = "#96b5b4";
      base0D = "#8fa1b3";
      base0E = "#b48ead";
      base0F = "#ab7967";
    };
    fonts = {
      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;
      monospace = {
        package = pkgs.hack-font;
        name = "Hack";
      };
    };
    targets.logseq.path = "notes";
  };

  environment = {
    defaultPackages = lib.mkForce (with pkgs; [
      vim
      tmux
    ]);
    sessionVariables = {
      EDITOR = "vim";
      NIXOS_OZONE_WL = "1";
      # krita fails to open
      #https://github.com/NixOS/nixpkgs/issues/82959#issuecomment-657306112
      QT_XCB_GL_INTEGRATION = "none";
    };

  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services = {
    pcscd.enable = true;
    udev.packages = with pkgs; [ yubikey-personalization ];
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
      # allowSFTP = false;
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
    xserver = {
      xkb = {
        layout = "us";
        variant = "dvorak";
      };
      autoRepeatInterval = 100;
      autoRepeatDelay = 200;
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;
    gc = {
      automatic = false;
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      # https://github.com/nix-community/nix-direnv#installation
      keep-outputs = true
      keep-derivations = true
      # useful when builder has faster network
      builders-use-substitutes = true
    '';
    settings = {
      extra-sandbox-paths = [ "/var/tmp/agenix-rekey" ];
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" flake.lib.username ];
      trusted-public-keys = [
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [
        "https://hydra.nixos.org"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
    };

    distributedBuilds = true;
    buildMachines = [{
      hostName = "server";
      # TODO: move to host config and pull from there?
      # publicHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt04Q7AY48Q5tJxFPxjJ3BZpBaR++R0jHRq7JVtBbkL";
      sshUser = flake.lib.username;
      # TODO: sshKey = config.age.secrets.id_ed25519.path;
      sshKey = "/home/${flake.lib.username}/.ssh/id_ed25519";
      # TODO: dynamically generate based on fs heirarchy
      systems = [ "x86_64-linux" ];
      maxJobs = 8;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }];
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.enableRedistributableFirmware = true;

  users = {
    mutableUsers = false;
    users.${flake.lib.username} = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$fUivdhuwqeMf6/iNYRX92/$sbxbgkQRAoD0uB9bcmYYC/7gssMAu.ZRk.JLU4qfmpA"; # `mkpasswd`
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/nxzI9MwJC1gMWCNDzdGUZsRvsCdNBqaH5iJwreqHc" # /secrets/id_ed25519.age
      ];
      group = "users";
      extraGroups = [
        "audio"
        "video"
        "input"
        "dialout"
        "docker"
        "i2c"
        "wheel"
        "networkmanager"

        "libvirtd"
      ];
    };
  };
}
