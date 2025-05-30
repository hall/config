{ lib, config, pkgs, ... }: {
  services = {
    syncthing.settings.folders.stash.path = lib.mkForce "/var/lib/stash";

    stash = {
      # https://github.com/NixOS/nixpkgs/pull/380462
      enable = true;
      group = "syncthing";

      username = "hall";
      passwordFile = config.age.secrets.luks.path;

      # TODO: why are these needed?
      jwtSecretKeyFile = pkgs.writeText "jwt_secret_key" "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
      sessionStoreKeyFile = pkgs.writeText "session_store_key" "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";

      mutableSettings = false;
      settings = {
        stash = [{ path = "${config.services.stash.dataDir}/content"; }];

        ui.frontPageContent = [ ];
      };

      mutablePlugins = false;
      plugins =
        let
          src = pkgs.fetchFromGitHub {
            owner = "stashapp";
            repo = "CommunityScripts";
            rev = "9b6fac4934c2fac2ef0859ea68ebee5111fc5be5";
            hash = "sha256-PO3J15vaA7SD4r/LyHlXjnpaeYAN9Q++O94bIWdz7OA=";
          };
        in
        [
          (pkgs.runCommand "stashNotes" { inherit src; } ''
            mkdir -p $out/plugins
            cp -r $src/plugins/stashNotes $out/plugins/stashNotes
          '')
          (pkgs.runCommand "Theme-Plex" { inherit src; } ''
            mkdir -p $out/plugins
            cp -r $src/themes/Theme-Plex $out/plugins/Theme-Plex
          '')
        ];

      mutableScrapers = false;
      scrapers =
        let
          src = pkgs.fetchFromGitHub {
            owner = "stashapp";
            repo = "CommunityScrapers";
            rev = "2ece82d17ddb0952c16842b0775274bcda598d81";
            hash = "sha256-AEmnvM8Nikhue9LNF9dkbleYgabCvjKHtzFpMse4otM=";
          };
        in
        [
          (pkgs.runCommand "FTV" { inherit src; } ''
            mkdir -p $out/scrapers/FTV
            cp -r $src/scrapers/FTV.yml $out/scrapers/FTV
          '')
        ];
    };
  };
}
