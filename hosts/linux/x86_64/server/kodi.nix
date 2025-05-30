{ pkgs, flake, lib, ... }:
let
  kodi = pkgs.kodi.withPackages (p: with p; [
    # artic: zephyr - reloaded
    # netflix
    # flake.packages.hulu
    # disney+
    # crunchyroll
    jellyfin
    # joystick
    # youtube
    steam-library
    (steam-launcher.overrideAttrs (old: {
      version = "3.7.11";
      src = pkgs.fetchFromGitHub rec {
        owner = "teeedubb";
        repo = owner + "-xbmc-repo";
        rev = "8d0972909c3f1d0cd9e435e77f8b1f59314d52f0";
        sha256 = "sha256-IYxl6X20qcnr1D/pNMOKBW9FfH9cXYon4Qi+wd7EvtI=";
      };
      postInstall = with pkgs; old.postInstall + ''
        substituteInPlace $out/share/kodi/addons/script.steam.launcher/resources/scripts/steam-launcher.sh \
          --replace "wmctrl" "${wmctrl}/bin/wmctrl"
      '';
    }))
    libretro
  ]);
in
{

  environment.etc."/xdg/openbox/autostart".text = ''
    xset -dpms     # Disable DPMS (Energy Star) features
    xset s off     # Disable screensaver
    xset s noblank # Don't blank video device
  '';

  services.pipewire = {
    # socketActivation = false;
    wireplumber.extraConfig.av = {
      "session.suspend-timeout-seconds" = 0;
      "node.pause-on-idle" = false;
    };
  };
  # Start WirePlumber (with PipeWire) at boot.
  systemd.user.services.wireplumber.wantedBy = [ "default.target" ];
  users.users.${flake.lib.username}.linger = true; # keep user services running

  networking.firewall = {
    allowedTCPPorts = [
      8081 # web server
      9090 # jsonrpc
    ];
    allowedUDPPorts = [
      9777 # event server
    ];
  };

  environment.systemPackages = with pkgs; [
    # useful for directing specific application audio to different output devices (television vs ceiling speakers)
    ncpamixer
    gdb # for stacktraces
  ];

  systemd.user.services.kodi = {
    description = "kodi as systemd service";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${kodi}/bin/kodi --standalone";
      Restart = "on-failure";
    };
    environment.KODI_AE_SINK = "ALSA";
  };

  home-manager.users.${flake.lib.username}.programs.kodi = {
    enable = true;
    package = kodi;
    addonSettings = {
      # https://github.com/teeedubb/teeedubb-xbmc-repo/blob/master/script.steam.launcher/resources/settings.xml
      "script.steam.launcher" = {
        SteamLinux = "${pkgs.steam}/bin/steam";
        KodiLinux = "${kodi}/bin/kodi";
        # don't modify kodi
        QuitKodi = "2";
      };
      # https://github.com/aanderse/plugin.program.steam.library/blob/master/resources/settings.xml
      "plugin.program.steam.library" = {
        steam-id = "76561199225094946";
        # TODO: move to 
        steam-key = "37913698D54C745129CA9195AFC6D243";
        steam-exe = "${pkgs.steam}/bin/steam";
        steam-path = "~/.steam";
        steam-args = "-bigpicture -fullscreen";
      };
    };

    # settings = {
    #   # addons managed by nix
    #   general = {
    #     addonupdates = "2";
    #     addonnotifications = "false";
    #   };
    #   locale = {
    #     timezonecountry = "United States";
    #     timezone = "America/New_York";
    #   };
    #   lookandfeel = {
    #     # some kids media requires CJK font
    #     font = "CJK - Spoqa + Inter";
    #   };
    #   services = {
    #     devicename = config.networking.hostName;
    #     webserver = "true";
    #     webserverport = "8080";
    #     webserverauthentication = "false";
    #     webserverusername = "kodi";
    #     webserverpassword = "";
    #     webserverssl = "false";
    #   };
    # };
  };

  services.upower.enable = true;
  hardware.bluetooth.enable = true;

  services.xserver = {
    enable = true;
    # a basic window manager to keep things simple
    windowManager.openbox.enable = true;
    # prevent the screen from ever going blank - turn the tv off when you're done using it
    extraConfig = ''
      Section "Extensions"
        Option "DPMS" "false"
      EndSection
    '';
    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';
  };

  # ensure the mouse cursor stays hidden
  # services.unclutter.enable = true;

  # TODO: https://github.com/xbmc/xbmc/issues/26122#issuecomment-2557393968
  systemd.user.services.pipewire.environment.PIPEWIRE_DEBUG = "W,pw.*:I,spa.audioadapter:X";

  # lightdm didn't work out of the box inside an nspawn container so prefer sddm
  services.displayManager = {
    sddm.enable = true;
    defaultSession = "none+openbox";
    autoLogin = {
      enable = true;
      user = flake.lib.username;
    };
  };
}

