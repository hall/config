{ lib, flake }: {
  # title = "Media";
  # icon = "mdi:bookshelf";
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

      }) [ "Player" "Requests" "Downloads" "Movies" "Shows" "Music" "Books" "Indexer" ];
}
