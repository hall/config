# NUC11PAHi7, 88:AE:DD:05:C9:46, F2 to enter bios
{ lib, pkgs, flake, config, ... }: {
  imports = [ flake.inputs.hardware.nixosModules.intel-nuc-8i7beh ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hyperion.enable = true;

  age.secrets.namecheap.file = ../../../../secrets/namecheap.age;
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = flake.lib.email;
      dnsProvider = "namecheap";
      credentialsFile = "/run/secrets/namecheap";
    };
    certs."${flake.lib.hostname}" = {
      domain = "*.${flake.lib.hostname}";
    };
  };

  services = {

    nginx = {
      enable = true;
      virtualHosts = {
        "esphome.${flake.lib.hostname}" = {
          enableACME = true;
          acmeRoot = null;
          locations."/".proxyPass = "http://127.0.0.1:${builtins.toString config.services.esphome.port}";
          # locations."/".proxyPass = "http://127.0.0.1:${config.services.esphome.port}";
        };
      };
    };

    esphome.enable = true;

    mosquitto = {
      # /var/lib/mosquitto
      # enable = true;
      settings = {
        listener = 1883;
        allow_anonymous = true;
        connection_messages = false;
      };
    };
    zigbee2mqtt = {
      # /var/lib/zigbee2mqtt
      # enable = true;
      # settings = {
      #   homeassistant = config.services.home-assistant.enable;
      #   permit_join = true;
      #   serial = {
      #     port = "/dev/ttyACM1";
      #   };
      # };
    };

    iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };

  environment.systemPackages = with pkgs; [ iperf ];

}
