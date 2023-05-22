{ lib, flake }: {
  title = "Settings";
  icon = "mdi:cog";
  views = builtins.map
    (v:
      let lower = lib.strings.toLower v; in
      {
        title = lower;
        path = v;
        panel = true;
        cards = [{
          type = "custom:internal-iframe";
          path = "/${lower}";
        }];

      }) [ "config" "hacs" "logbook" "history" "developer-tools" "map" "media-browser" ];
}
