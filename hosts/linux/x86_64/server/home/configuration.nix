{ flake, ... }: {

  services.home-assistant.config = {
    # https://www.home-assistant.io/integrations/default_config/
    default_config = { };
    zeroconf = { };
    http = {
      server_host = "::1";
      trusted_proxies = [ "::1" ];
      use_x_forwarded_for = true;
    };
    prometheus = { };
    homeassistant = {
      external_url = "https://home.${flake.lib.hostname}";
      # TODO: be less imperial swine :)
      # unit_system = "metric";
      # temperature_unit = "C";
      # longitude = 0;
      # latitude = 0;
    };
    frontend.themes = "!include_dir_merge_named themes";
    circadian_lighting = {
      min_colortemp = 2906; # for elgato key light
    };
    switch = [{
      platform = "circadian_lighting";
      lights_ct = [
        "light.key"
      ];
    }];
    sensor = {
      platform = "worxlandroid";
      host = "robotic-mower";
      pin = "0121";
    };
    notify = [{
      platform = "group";
      name = "phones";
      services = [
        { action = "mobile_app_phone"; }
        { action = "mobile_app_pixel_8_pro"; }
      ];
    }];
  };
}
