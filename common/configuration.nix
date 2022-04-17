{ lib, pkgs, unstablePkgs, ... }:

{
  imports = [
    ./home-manager.nix
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.05"; # Did you read the comment?


  environment = {
    systemPackages = with pkgs; [
      git
    ];

    sessionVariables = {
      CALIBRE_USE_DARK_PALETTE = "1";
      MOZ_USE_XINPUT2 = "1";
      EDITOR = "nvim";
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

  networking = {
    # wireless.enable = true;
    networkmanager.enable = true;
  };

  services = {
    xserver = {
      desktopManager.gnome.enable = true;
      layout = "us";
      xkbVariant = "dvorak";
    };
  };

  hardware.bluetooth.enable = true;

  nix = {
    generateRegistryFromInputs = true;
    generateNixPathFromInputs = true;
    package = pkgs.nixUnstable;
    gc.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
      allow-unsafe-native-code-during-evaluation = true
      # keep-outputs = true
      # keep-derivations = true
    '';
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    dconf.enable = true;
    wireshark.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
  };

}
