{ pkgs, musnix, flake, lib, ... }: {

  imports = [ (import "${flake.inputs.mobile}/lib/configuration.nix" { device = "pine64-pinephonepro"; }) ];

  fileSystems."/home" = {
    device = "/dev/disk/by-label/home";
    fsType = "ext4";
  };

  boot = {
    # overwrite nixos-generators setting with the one from nixos-mobile
    loader.generic-extlinux-compatible.enable = lib.mkForce true;
    postBootCommands = ''
      # usb audio interface does not work in the default `device` mode
      # and automatic mode switching is not functional
      echo host | tee /sys/class/usb_role/fe800000.usb-role-switch/role
    '';
  };

  hardware.sensor.iio.enable = true;

  users.users = {
    geoclue.extraGroups = [ "networkmanager" ];
    ${flake.lib.username}.initialPassword = "1234";
  };
  # TODO: currently fails to start systemd service
  networking.firewall.enable = false;
  musnix.enable = true;

  xdg.portal.enable = true;

  services = {
    gnome.gnome-keyring.enable = true;
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

    # TODO: not sure why this is enabled
    xserver.displayManager.lightdm.enable = lib.mkForce false;
    xserver.desktopManager.phosh = {
      enable = true;
      user = flake.lib.username;
      group = "users";
      # for better compatibility with x11 applications
      phocConfig.xwayland = "immediate";
    };

    geoclue2 = {
      enable = true;
      # appConfig = {
      #   gammastep = {
      #     isAllowed = true;
      #     isSystem = true;
      #     users = [ "1000" ];
      #   };
      #   "sm.puri.Phosh" = {
      #     isAllowed = true;
      #     isSystem = true;
      #   };
      # };
    };
  };

  programs.calls.enable = true;

  location.provider = "geoclue2";

  environment.variables = {
    WEBKIT_FORCE_SANDBOX = "0"; # workaround for epiphany
  };

}
