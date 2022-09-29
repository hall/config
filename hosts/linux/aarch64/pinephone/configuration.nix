{ pkgs, musnix, flake, lib, ... }: {

  imports = [ (import "${flake.inputs.mobile}/lib/configuration.nix" { device = "pine64-pinephonepro"; }) ];

  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/disk/by-label/NIXOS_SYSTEM";
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/disk/by-label/home";
      fsType = "ext4";
    };
  };

  boot = {
    postBootCommands = ''
    # usb audio interface does not work in the default `device` mode
    # and automatic mode switching is not functional
    echo host | tee /sys/class/usb_role/fe800000.usb-role-switch/role
  '';
  };

  # users.users.geoclue.extraGroups = [ "networkmanager" ];
  musnix.enable = true;

  services = {
    effects = {
      enable = true;
      kernel = "controlC3";
    };
    # wifi.enable = true;

    fwupd.enable = true;
    flatpak = {
      enable = true;
      # dialect
      # bitwarden
    };

    xserver.desktopManager.phosh = {
      enable = true;
      user = flake.username;
      group = "users";
      phocConfig.xwayland = "immediate";
    };

    geoclue2 = {
      enable = true;
      appConfig.gammastep = {
        isAllowed = true;
        isSystem = true;
        users = [ "1000" ];
      };
    };

    redshift = {
      enable = true;
      package = pkgs.gammastep;
      executable = "/bin/gammastep";
    };
  };

  programs.calls.enable = true;

  location.provider = "geoclue2";

  environment = {
    variables = {
      WEBKIT_FORCE_SANDBOX = "0"; # workaround for epiphany
    };

    systemPackages = with pkgs; [
      # purple-matrix
      # purple-slack
      # tdlib-purple
      pinentry-curses
      pinentry-gnome

      lingot

      element-desktop
      protonmail-bridge

      chatty
      megapixels
      epiphany
      newsflash

      spot
      drawing
      fragments
      banking
      tootle
      # waydroid
      tdesktop
      pure-maps
      siglo
      # ardour

      usbutils
      libusb

      gnome-podcasts
      gnome-photos
    ] ++ (with pkgs.gnome; [
      geary # email
      totem # videos
      gedit # editor
      nautilus # files
      eog # images
      fractal # matrix
      giara # reddit

      gnome-terminal
      # gnome-connections
      gnome-calendar
      gnome-contacts
      gnome-calculator
      gnome-clocks
      #gnome-documents # broken
      gnome-maps
      gnome-music
      gnome-weather
      gnome-system-monitor
      gnome-sound-recorder
      gnome-todo
      gnome-notes
      # gnome-books
      gnome-screenshot
      gnome-dictionary
      gnome-disk-utility
    ]) ++ (with flake.packages; [
      effects
      itd
    ]);
  };

}
