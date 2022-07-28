{ pkgs, flake, ... }:
{
  imports = [
    ./home-manager.nix
  ];

  system = {
    # https://nixos.org/manual/nixos/stable/release-notes.html#sec-release-22.05
    stateVersion = "22.05";
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
    # settings.trusted-users = [ flake.username ];
    generateRegistryFromInputs = true;
    generateNixPathFromInputs = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      allow-unsafe-native-code-during-evaluation = true
      # keep-outputs = true
      # keep-derivations = true
    '';
    settings = {
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

  programs = {
    dconf.enable = true;
    # wireshark.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
  };


}
