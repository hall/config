{ config, lib, flake, ... }: {

  # config = with builtins; with lib.attrsets; mapAttrs'
  #   (f: v: nameValuePair
  #     (vars.config v))
  #   (recursiveMerge (attrValues (mapAttrs
  #     (f: v: (import ./${f} { inherit flake; }))
  #     (removeAttrs (readDir ./.) [ "default.nix" "speaker.yaml" ])
  #   )));


  # TODO: how to get to /var/lib/esphome?
  environment.etc."var/lib/esphome/.common.yaml".text = with builtins; toJSON (import ./.common.nix { inherit flake; });
  environment.etc."var/lib/esphome/zigbee.yaml".text = with builtins; toJSON (import ./zigbee.nix { inherit config lib; });

  environment.etc."var/lib/esphome/speaker.yaml".source = ./speaker.yaml;
  services = {
    esphome = {
      enable = true;
      usePing = true;
    };
    nginx.virtualHosts."esphome.${flake.lib.hostname}" = {
      useACMEHost = flake.lib.hostname;
      acmeRoot = null;
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:${builtins.toString config.services.esphome.port}";
        proxyWebsockets = true;
      };
    };
  };
}
