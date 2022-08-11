{ pkgs, musnix, flake, ... }:
{
  imports = [
    ./hardware.nix
    (import "${flake.inputs.mobile}/lib/configuration.nix" { device = "pine64-pinephonepro"; })
  ];

  musnix.enable = true;

  boot.postBootCommands = ''
    # usb audio interface does not work in the default `device` mode
    # and automatic mode switching is not functional
    echo host | tee /sys/class/usb_role/fe800000.usb-role-switch/role
  '';

  # users.users.geoclue.extraGroups = [ "networkmanager" ];

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
    };

    xserver.desktopManager.phosh = {
      enable = true;
      user = flake.username;
      group = "users";
      phocConfig = {
        xwayland = "immediate";
      };
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

  sound.enable = true;
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
      fmit
      # cozy
      sooperlooper

      # element-desktop
      protonmail-bridge

      # talosctl
      # nextcloud-client
      # newsflash

      chatty
      megapixels
      epiphany
      newsflash
      giara
      nheko

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
      gnome-books
      gnome-screenshot
      gnome-dictionary
      gnome-disk-utility
    ]) ++ (with flake.packages; [
      effects
    ]);
  };

  programs.calls.enable = true;

}
