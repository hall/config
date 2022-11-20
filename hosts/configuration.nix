{ lib, pkgs, flake, age, ... }:
{
  imports = [
    ./home-manager.nix
  ];

  # https://nixos.org/manual/nixos/stable/release-notes.html#sec-release-22.05
  system.stateVersion = "22.05";

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode-extension-ms-toolsai-jupyter"
    "vscode-extension-ms-vscode-cpptools"
    "slack"
    "steam"
    "steam-original"
    "steam-runtime"
    "steam-run"
    "1password"
  ];

  age.secretsDir = "/run/secrets";

  security.sudo.execWheelOnly = true;

  environment = {
    defaultPackages = lib.mkForce (with pkgs; [
      vim
      tmux
    ]);
    sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
      EDITOR = "vim";
    };

    gnome.excludePackages = with pkgs; [
      gnome.cheese
      gnome.gnome-music
      gnome.gedit
      gnome-tour
      gnome-passwordsafe
      epiphany # browser
      gnome.seahorse # passwords
      gnome.gnome-characters
    ];
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      # allowSFTP = false;
      kbdInteractiveAuthentication = false;
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
    xserver = {
      layout = "us";
      xkbVariant = "dvorak";
      autoRepeatInterval = 300;
      autoRepeatDelay = 500;
    };
  };


  nix = {
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
      trusted-users = [ "root" flake.username ];
      experimental-features = "nix-command flakes";
    };

    distributedBuilds = true;
    buildMachines = [{
      hostName = "tv";
      sshUser = flake.username;
      sshKey = "/run/secrets/id_ed25519";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      maxJobs = 8;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }];
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.enableRedistributableFirmware = true;

}
