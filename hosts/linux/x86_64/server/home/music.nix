{ flake, ... }: {
  networking.firewall = {
    allowedTCPPorts = [
      8097 # music-assistant
    ];
    # allowedUDPPorts = [
    #   8097 # music-assistant
    # ];
  };
  services = {
    nginx.virtualHosts."music-assistant.${flake.lib.hostname}" = {
      useACMEHost = flake.lib.hostname;
      acmeRoot = null;
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:8095";
        proxyWebsockets = true;
      };
    };
    music-assistant = {
      enable = true;
      providers = [
        "spotify"
        "hass"
        "jellyfin"
      ];
    };
  };
}
