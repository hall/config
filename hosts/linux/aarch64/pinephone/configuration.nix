{ pkgs, musnix, flake, lib, ... }: {

  imports = [ (import "${flake.inputs.mobile}/lib/configuration.nix" { device = "pine64-pinephonepro"; }) ];

  fileSystems."/home" = {
    device = "/dev/disk/by-label/home";
    fsType = "ext4";
  };

  boot = {
    postBootCommands = ''
    # usb audio interface does not work in the default `device` mode
    # and automatic mode switching is not functional
    echo host | tee /sys/class/usb_role/fe800000.usb-role-switch/role
  '';
  };

  hardware.sensor.iio.enable = true;
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
      user = flake.lib.username;
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

  environment.variables = {
    WEBKIT_FORCE_SANDBOX = "0"; # workaround for epiphany
  };

}
