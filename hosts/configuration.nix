{ pkgs, flake, ... }:
{
  imports = [
    ./home-manager.nix
  ];

  system = {
    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    stateVersion = "21.05"; # Did you read the comment?
    autoUpgrade.enable = true;
  };


  environment = {
    systemPackages = with pkgs; [
      git
      tmux
      rbw
      pinentry
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

  services = {
    xserver = {
      layout = "us";
      xkbVariant = "dvorak";
    };
  };


  nix = {
    trustedUsers = [ flake.username ];
    generateRegistryFromInputs = true;
    generateNixPathFromInputs = true;
    # gc.automatic = true;
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
    # wireshark.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
  };


}
