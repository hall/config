{ lib, pkgs, flake, age, ... }:
{
  imports = [
    ./home-manager.nix
  ];

  system = {
    # https://nixos.org/manual/nixos/stable/release-notes.html#sec-release-22.05
    stateVersion = "22.05";
    autoUpgrade.enable = true;
  };

  age.secretsDir = "/run/secrets";

  security.sudo.execWheelOnly = true;

  environment = {
    defaultPackages = lib.mkForce (with pkgs; [
      vim
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
      epiphany
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
    # distributedBuilds = true;
    # buildMachines = [
    #   {
    #     hostName = "eu.nixbuild.net";
    #     system = "x86_64-linux";
    #     # system = "aarch64-linux";
    #     maxJobs = 100;
    #     supportedFeatures = [ "benchmark" "big-parallel" ];
    #   }
    # ];
    generateRegistryFromInputs = true;
    generateNixPathFromInputs = true;
    gc = {
      automatic = false;
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      # https://github.com/nix-community/nix-direnv#installation
      keep-outputs = true
      keep-derivations = true
    '';
    settings = {
      trusted-users = [ "root" flake.username ];
      experimental-features = "nix-command flakes";
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.enableRedistributableFirmware = true;

  programs = {
    dconf.enable = true;
    # wireshark.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
    # ssh = {
    #   extraConfig = ''
    #     Host eu.nixbuild.net
    #     PubkeyAcceptedKeyTypes ssh-ed25519
    #     IdentityFile /home/bryton/.ssh/nixbuild
    #   '';
    #   knownHosts = {
    #     nixbuild = {
    #       hostNames = [ "eu.nixbuild.net" ];
    #       publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    #     };
    #   };
    # };
  };
}
