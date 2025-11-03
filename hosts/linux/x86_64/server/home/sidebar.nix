{ ... }: {
  services.home-assistant.config.frontend.extra_module_url = [
    "/hacsfiles/custom-sidebar/custom-sidebar-json.js?v6.5.0"
  ];
  environment.etc."home-assistant/www/sidebar-config.json".text = builtins.toJSON {
    sidebar_editable = false;
    order = [
      { item = "overview"; }
      { item = "lovelace-media"; match = "href"; }
      { item = "to-do"; name = "TODO"; }
      { item = "energy"; }

      { item = "hacs"; bottom = true; }
      { item = "lovelace-admin"; bottom = true; match = "href"; }
      { item = "settings"; bottom = true; }

      { item = "Developer tools"; bottom = true; hide = true; }
      { item = "map"; bottom = true; hide = true; }
      { item = "media-browser"; hide = true; match = "href"; }
      { item = "logbook"; hide = true; }
      { item = "history"; hide = true; }
    ];
  };
}
