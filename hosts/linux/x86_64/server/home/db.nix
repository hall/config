{ ... }: {
  # TODO: alloy shouldn't need this?
  networking.firewall.allowedTCPPorts = [ 5432 ];
  services = {
    home-assistant.config.recorder.db_url = "postgresql://@/hass";
    postgresql = {
      enable = true;
      ensureDatabases = [ "hass" ];
      ensureUsers = [
        { name = "hass"; ensureDBOwnership = true; }
        { name = "alloy"; }
      ];
    };
  };
}
