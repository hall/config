{ config, ... }: {
  services.home-assistant.config.frontend.extra_module_url = [
    "/hacsfiles/custom-sidebar/custom-sidebar-json.js?v1.0.0"
  ];
  environment.etc."${config.services.home-assistant.configDir}/www/sidebar-config.json".text = builtins.toJSON {
    sidebar_editable = false;
    order = [
      { item = "overview"; }
      { item = "energy"; }
      { item = "to-do lists"; }
      { item = "hacs"; bottom = true; }
      { item = "map"; bottom = true; }
      { item = "developer tools"; bottom = true; }
      { item = "settings"; bottom = true; }
      { item = "media-browser"; hide = true; }
      { item = "logbook"; hide = true; }
      { item = "history"; hide = true; }
    ];
  };
}
