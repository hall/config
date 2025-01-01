{ flake, ... }: {
  services = {
    mosquitto = {
      enable = true;
      listeners = [{
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings = {
          allow_anonymous = true;
          # keepalive = 15;
          # version = "5";
        };
      }];
    };
    nginx.virtualHosts."mqtt.${flake.lib.hostname}" = {
      useACMEHost = flake.lib.hostname;
      acmeRoot = null;
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:1883";
        proxyWebsockets = true;
      };
    };

    zigbee2mqtt = {
      enable = true;
      settings = {
        frontend = true;
        home-assistant = true;
        serial = {
          # TODO: centralize static addresses
          port = "tcp://192.168.86.11:6638";
        };
      };
    };
    nginx.virtualHosts."zigbee.${flake.lib.hostname}" = {
      useACMEHost = flake.lib.hostname;
      acmeRoot = null;
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:8080";
        proxyWebsockets = true;
      };
    };
  };
}
