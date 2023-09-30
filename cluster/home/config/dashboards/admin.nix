{ lib, flake }: {
  title = "Admin";
  icon = "mdi:console-line";
  views = builtins.map
    (v:
      let lower = lib.strings.toLower v; in
      {
        title = v;
        path = lower;
        panel = true;
        cards = [{
          type = "iframe";
          url = "https://${lower}.${flake.lib.hostname}";
        }];

      }) [ "Grafana" "ESPHome" "Sync" "Longhorn" "Prometheus" "Alertmanager" "Octoprint" "Zigbee" ];
}
