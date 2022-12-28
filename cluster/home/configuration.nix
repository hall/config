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
    #elevation:
    unit_system = "imperial";
    time_zone = "!secret timezone";
    external_url = "https://home.${flake.hostname}";
    internal_url = "https://home.${flake.hostname}";

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

  #media_source = {};
  #logger.default= "debug";
  weather = { };
  sun = { };
  config = { };
  history = { };
  logbook = { };
  stream = { };
  updater = { };
  map = { };
  mobile_app = { };
  discovery = { };
  system_health = { };
  prometheus = { };
  #transmission = {
  #  host = "https://downloads.${flake.hostname}/transmission/rpc";
  #  port = 443;
  # };
  python_script = { };
  recorder.db_url = "!secret postgresql";

  automation = import ./automations.nix { };
  script = import ./scripts.nix { inherit vars; };

  frontend = {
    # the `themes` directory is managed by HACS
    themes = "!include_dir_merge_named themes";
    extra_module_url = [
      "/hacsfiles/custom-sidebar/custom-sidebar.js"
      # "/hacsfiles/stack-in-card/stack-in-card.js"
      # "/hacsfiles/mini-graph-card/mini-graph-card-bundle.js"
      # "/hacsfiles/bar-card/bar-card.js"
      # "/hacsfiles/lovelace-card-templater/lovelace-card-templater.js"
    ];
  };


  lovelace = {
    mode = "yaml";
    resources = [
      {
        url = "/hacsfiles/ha-floorplan/floorplan.js";
        type = "module";
      }
    ];
    dashboards = {
      # lovelace-media = {
      #   mode = "yaml";
      #   filename = "dashboards/media.yaml";
      #   title = "Media";
      #   icon = "mdi:bookshelf";
      # };
      lovelace-admin = {
        mode = "yaml";
        filename = "dashboards/admin.yaml";
        title = "Admin";
        icon = "mdi:console-line";
      };
    };
  };

  #telegram-bot

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
        { service = "mobile_app_sm_n950u1"; }
        { service = "mobile_app_sm_g965u1"; }
      ];
    }
    {
      name = "matrix";
      platform = "matrix";
      default_room = "!secret matrix_room";
    }
    {
      name = "tv";
      platform = "kodi";
      host = "tv";
      username = "kodi";
      password = "!secret kodi";
    }
    # {
    #   name = "gotify";
    #   platform = "rest";
    #   resource = "http://gotify/message";
    #   method = "POST_JSON";
    #   headers.X-Gotify-Key = "!secret gotify_key";
    #   message_param_name = "message";
    #   title_param_name = "title";
    #   data.extras."client::display".contentType = "text/markdown";
    # }
  ];

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
  # device_tracker = [{
  #   platform = "luci";
  #   host = "router.lan";
  #   username = "root";
  #   password = "!secret router";
  #   ssl = true;
  #   verify_ssl = false;
  # }];
  # media_player = [{
  #   platform = "emby";
  #   host = "player.${flake.hostname}";
  #   api_key = "!secret jellyfin";
  #   ssl = true;
  #   port = 443;
  # }];
  # roomba = [{
  #   host = "vacuum";
  #   # continuous = false;
  #   blid = "!secret roomba_user";
  #   password = "!secret roomba_pass";
  # }];

  #mycroft.host= "picroft.lan";

  panel_iframe = {
    docs = {
      title = "Docs";
      icon = "mdi:file-document";
      url = "https://docs.${flake.hostname}";
    };
    photos = {
      title = "Photos";
      icon = "mdi:image";
      url = "https://photos.${flake.hostname}";
    };
    security = {
      title = "Security";
      icon = "mdi:security";
      url = "https://frigate.${flake.hostname}";
    };
  };

  # adaptive_lighting https://github.com/basnijholt/adaptive-lighting/issues/85
  circadian_lighting = { };

  switch = [{
    platform = "circadian_lighting";
    lights_rgb = [ "light.lights" ];
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
        "light.livingroom_light"
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
    # {
    #   platform = "dahua_vto";
    #   name = "doorbell";
    #   host = "doorbell";
    #   username = "admin";
    #   password = "!secret doorbell";
    # }
    {
      platform = "worxlandroid";
      host = "robotic-mower";
      pin = "!secret landroid";
    }
  ];

  alarm_control_panel = [{
    platform = "manual";
    name = "home";
  }];

}
