{ flake, lib, ... }: {
  imports = with builtins; (map (v: ./${v})
    (filter (v: v != "default.nix")
      (attrNames (readDir ./.))));

  services = {
    home-assistant = {
      enable = true;
      extraComponents = [
        "esphome"
        "met"
        "radio_browser"
        "isal"
      ];
      extraPackages = python3Packages: with python3Packages; [
        aiogithubapi
        androidtvremote2
        brother
        elgato
        govee-ble
        gtts
        ibeacon-ble
        ical
        kegtron-ble
        music-assistant-client
        psycopg2
        pychromecast
        pyipp
        pyschlage
        python-otbr-api
        roombapy
        venstarcolortouch
        wyoming
        zeroconf
      ];
      # `/var/lib` is harder to write to declaratively :/
      configDir = "/etc/home-assistant";
    };

    nginx.virtualHosts."home.${flake.lib.hostname}" = {
      useACMEHost = flake.lib.hostname;
      acmeRoot = null;
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:8123";
        proxyWebsockets = true;
      };
    };
  };

  # this thing tries to symlink to `/etc/home-assistant`
  systemd.services.home-assistant.preStart = lib.mkForce "";

  # remove redundant logging https://community.home-assistant.io/t/disable-logging-to-file/79496
  system.activationScripts.home-assistant-disable-logging = ''
    ln -sf /dev/null /etc/home-assistant/home-assistant.log
  '';
}
