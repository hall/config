{ flake, pkgs, ... }: {
  services.cage = {
    enable = true;
    user = flake.lib.username;
    program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    extraArguments = [ "-d" ];
    environment = {
      WLR_LIBINPUT_NO_DEVICES = "1"; # boot up even if no mouse/keyboard connected
    };
  };
  systemd.services."cage-tty1".wants = [ "dev-dri-card0.device" ];
  systemd.services."cage-tty1".after = [ "dev-dri-card0.device" ];
}
