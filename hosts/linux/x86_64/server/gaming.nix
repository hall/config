{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  services = {
    udev.packages = with pkgs; [
      # for 8bit pro 2 in switch mode
      game-devices-udev-rules
    ];
    keyd = {
      enable = true;
      keyboards = {
        gamepad = {
          # 8BitDo Pro 2
          ids = [
            # "057e:2009" # switch mode
            # "0fac:0ade" # "keyd virtual keyboard"
            "*"
          ];
          settings = {
            main = {
              "f3" = "command(systemctl start cec-toggle)";
            };
          };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    libcec
    # for steam-launcher
    wmctrl
    xdotool
    dconf
    # / for steam-launcher
    lutris
  ];
}
