{ lib, config, pkgs, ... }: {
  # age.secrets.stash = {
  #   rekeyFile = config.age.secrets.luks.rekeyFile;
  #   # rekeyFile = ./stash.age;
  #   owner = "stash";
  # };
  systemd.tmpfiles.rules = [
    "L+ ${config.services.stash.dataDir}/custom.css - - - - ${./custom.css}"
  ];
  services = {
    syncthing.settings.folders.stash.path = lib.mkForce "/var/lib/stash";

    stash = {
      # https://github.com/NixOS/nixpkgs/pull/380462
      enable = true;
      package = pkgs.stash.overrideAttrs (oldAttrs: rec {
        version = "0.29.3";
        src = pkgs.fetchFromGitHub {
          owner = "stashapp";
          repo = "stash";
          rev = "v${version}";
          hash = "sha256-FCF3BzBi1gGngz8Z7J94KajGaJafzGrEnfcqVs2rCws=";
        };
        # vendorHash = ""; # Uncomment and run to get the hash if needed
      });
      group = "syncthing";

      username = "hall";
      # passwordFile = config.age.secrets.stash.path;
      passwordFile = pkgs.writeText "password" "";

      # TODO: why are these needed?
      jwtSecretKeyFile = pkgs.writeText "jwt_secret_key" "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
      sessionStoreKeyFile = pkgs.writeText "session_store_key" "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";

      mutableSettings = false;
      settings = {
        stash = [{ path = "${config.services.stash.dataDir}/content"; }];
        ui.frontPageContent = [ ];
        database = "${config.services.stash.dataDir}/stash-go.sqlite";
        # username = "hall";
        # password = "";
        cssenabled = true;
      };

      mutablePlugins = false;
      plugins =
        let
          src = pkgs.fetchFromGitHub {
            owner = "stashapp";
            repo = "CommunityScripts";
            rev = "05b0e72fc13fdafa0009079c174558a565fa6842";
            hash = "sha256-24XQqcZtd33qmCvJWg8dRx9ECQNYgXYtJX09wwsHP2Y";
          };
        in
        [
          (pkgs.runCommand "stashNotes" { inherit src; } ''
            mkdir -p $out/plugins
            cp -r $src/plugins/stashNotes $out/plugins/stashNotes
          '')
          (pkgs.runCommand "Theme-Minimal" { inherit src; } ''
            mkdir -p $out/plugins
            cp -r $src/themes/Theme-Minimal $out/plugins/Theme-Minimal
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
