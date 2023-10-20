{ flake, vars, ... }: {
  # hacs:
  #   integrations:
  #     circadian lighting
  #     frigate
  #     dahua vto
  #     browser mod # TODO: not using?
  #   frontend:
  #     nord theme
  #     ha floorplan
  #     custom sidebar
  #   automations:
  #     shellies discovery
  #
  #
  #   landroid-cloud
  #   hifiberry
  #   petkit?

  homeassistant = {
    name = "Home";
    latitude = "!secret latitude";
    longitude = "!secret longitude";
    #elevation = "!secret elevation";
    unit_system = "imperial";
    country = "US";
    currency = "USD";
    time_zone = "!secret timezone";
    external_url = "https://home.${flake.lib.hostname}";
    internal_url = "https://home.${flake.lib.hostname}";

    auth_providers = [{
      type = "trusted_networks";
      trusted_networks = [
        "192.168.1.0/24"
        "10.42.0.0/16"
        "fd00::/8"
        "10.0.0.0/8"
      ];
      allow_bypass_login = true;
    }
      { type = "homeassistant"; }];
  };
  http = {
    use_x_forwarded_for = true;
    trusted_proxies = [
      "10.0.0.0/8"
      "10.42.0.0/16"
      "127.0.0.0/8"
    ];
  };

  # https://www.home-assistant.io/integrations/default_config/
  automation = "!include automations.yaml";
  config = { };
  energy = { };
  frontend = {
    # the `themes` directory is managed by HACS
    themes = "!include_dir_merge_named themes";
    extra_module_url = [
      "/hacsfiles/custom-sidebar-v2/custom-sidebar-v2.js"
      "/local/card-mod.js"
      # "/hacsfiles/stack-in-card/stack-in-card.js"
      # "/hacsfiles/mini-graph-card/mini-graph-card-bundle.js"
      # "/hacsfiles/bar-card/bar-card.js"
      # "/hacsfiles/lovelace-card-templater/lovelace-card-templater.js"
    ];
  };
  history = { };
  homeassistant_alerts = { };
  logbook = { };
  #logger.default= "debug";
  map = { };
  #media_source = {};
  mobile_app = { };
  person = [
    {
      name = "Bryton";
      id = "bryton";
      device_trackers = [ "device_tracker.sm_n950u1" ];
    }
    {
      name = "Kristin";
      id = "kristin";
      device_trackers = [ "device_tracker.sm_g965u1" ];
    }
  ];
  scene = "!include scenes.yaml";
  script = "!include scripts.yaml";
  sun = { };

  weather = { };
  stream = { };
  discovery = { };
  system_health = { };
  prometheus = { };
  input_boolean = { };
  python_script = { };
  recorder.db_url = "!secret postgresql";

  lovelace = {
    resources = [
      {
        url = "/hacsfiles/ha-floorplan/floorplan.js";
        type = "module";
      }
    ];
    dashboards = {
      lovelace-admin = {
        mode = "yaml";
        filename = "dashboards/admin.yaml";
        title = "Admin";
        icon = "mdi:console-line";
      };
    };
  };

  matrix = {
    homeserver = "https://matrix.org";
    username = "!secret matrix_user";
    password = "!secret matrix_pass";
    rooms = [ "!secret matrix_room" ];
    commands = [{
      name = "theme";
      word = "theme";
    }];
  };

  notify = [
    {
      name = "phones";
      platform = "group";
      services = [
        { service = "mobile_app_phone"; }
        { service = "mobile_app_pixel_8_pro"; }
      ];
    }
    {
      name = "matrix";
      platform = "matrix";
      default_room = "!secret matrix_room";
    }
  ];

  # adaptive_lighting https://github.com/basnijholt/adaptive-lighting/issues/85
  circadian_lighting = { };

  switch = [{
    platform = "circadian_lighting";
    lights_ct = [ "light.lights" ];
    # lights_brightness = [ "light.switches" ];
    #prefer_rgb_color: true
    #min_color_temp: 1000
  }];

  light = [
    {
      platform = "group";
      name = "lights";
      entities = [
        "light.office"
        "light.livingroom"
        "light.bedroom"
      ];
    }
    {
      platform = "group";
      name = "switches";
      entities = [
        "light.livingroom_light_switch"
        "light.bedroom_light_switch"
        "light.office_light_switch"
        "light.guest_light_switch"
      ];
    }
    {
      platform = "group";
      name = "nightstands";
      entities = [
        "light.nightstand_light_left"
        "light.nightstand_light_right"
      ];
    }
    {
      platform = "group";
      name = "livingroom";
      entities = [
        "light.livingroom_light_switch"
        "light.livingroom_lamp"
        "light.livingroom_table_lamp"
      ];
    }
    {
      platform = "group";
      name = "bedroom";
      entities = [
        "light.bedroom_light"
        "light.unassigned_light"
      ];
    }
    {
      platform = "group";
      name = "office";
      entities = [
        "light.office_light"
      ];
    }
  ];

  sensor = [
    {
      platform = "worxlandroid";
      host = "robotic-mower";
      pin = "!secret landroid";
    }
    {
      platform = "integration";
      source = "sensor.space_heater_power_power";
      unique_id = "space_heater_energy";
      name = "Space Heater";
      unit_prefix = "k";
      round = 2;
    }
    {
      platform = "integration";
      source = "sensor.treadmill_power_power";
      unique_id = "treadmill_energy";
      name = "Treadmill";
      unit_prefix = "k";
      round = 2;
    }
    {
      platform = "integration";
      source = "sensor.printer_power_power";
      unique_id = "printer_energy";
      name = "Printer";
      unit_prefix = "k";
      round = 2;
    }
    {
      platform = "integration";
      source = "sensor.recirculating_pump_power_power";
      unique_id = "recirculating_pump_energy";
      name = "Recirculating Pump";
      unit_prefix = "k";
      round = 2;
    }
  ];

  alarm_control_panel = [{
    platform = "manual";
    name = "home";
  }];

}
