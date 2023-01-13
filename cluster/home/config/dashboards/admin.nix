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
          url = "https://${lower}.${flake.hostname}";
        }];

      }) [ "Grafana" "ESPHome" "Frigate" "Longhorn" "Prometheus" "Alertmanager" "Octoprint" "Zigbee" "RSS" ];
  # bitwarden adguard
}
