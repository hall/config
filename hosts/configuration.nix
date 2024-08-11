{ config, lib, pkgs, flake, ... }: {
  # https://nixos.org/manual/nixos/stable/release-notes.html
  # https://nix-community.github.io/home-manager/release-notes.xhtml
  system.stateVersion = "24.05";

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "1password"
      "google-chrome"
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
    ];

    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  age.rekey = {
    masterIdentities = [ "/home/bryton/.ssh/id_ed25519" ];
    # force secrets to be copied to remote host
    derivation = flake.nixosConfigurations.${config.networking.hostName}.config.age.rekey.derivation;
    # TODO: switch to `local`?
    storageMode = "derivation";
  };

  security.sudo.execWheelOnly = true;

  stylix = {
    image = config.lib.stylix.pixel "base0A";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ocean.yaml";
    cursor = {
      package = pkgs.material-cursors;
      # name = "";
    };
    fonts = {
      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;
      monospace = {
        package = pkgs.hack-font;
        name = "Hack";
      };
    };
  };

  environment = {
    defaultPackages = lib.mkForce (with pkgs; [
      vim
      tmux
    ]);
    sessionVariables.EDITOR = "vim";

    gnome.excludePackages = with pkgs; [
      epiphany # browser
      gnome-tour
      gnome-passwordsafe
      gedit
      geary
      cheese
      seahorse # passwords
    ] ++ (with gnome;[
      gnome-music
      gnome-notes
      gnome-characters
      gnome-user-docs
    ]);
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
      excludePackages = with pkgs; [ xterm ];
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

  users.users.${flake.lib.username} = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "media"
      "dialout"
      "docker"
      "i2c"
      "input"
      "wheel"
      #"wireshark"

      "feedbackd"
      "video"
      "networkmanager"
    ];
  };
}
