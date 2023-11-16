{ flake, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.stash;
  opt = options.services.stash;
in
{

  options.services.stash = {
    enable = mkEnableOption (mdDoc "Stash");

    user = mkOption {
      type = types.str;
      default = "stash";
      description = mdDoc "User under which the webserver runs.";
    };

    group = mkOption {
      type = types.str;
      default = "stash";
      description = mdDoc "Group under which the webserver runs.";
    };

    host = mkOption {
      type = types.str;
      default = "localhost";
      description = mdDoc "Address on which to start webserver.";
    };

    port = mkOption {
      type = types.port;
      default = 9999;
      description = mdDoc "Port on which to start webserver.";
    };

    externalHost = mkOption {
      type = types.str;
      default = "";
      description = mdDoc "Needed in some cases when you use a reverse proxy.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/stash";
      description = mdDoc "Path where to store data files.";
    };

  };

  config = mkIf cfg.enable (
    let
      stashPython = pkgs.python3.withPackages (ps: with ps;
        [
          cloudscraper
          configparser
          progressbar
          requests
        ]);
      stashPackages = with pkgs; [
        stashPython
        bashInteractive
        openssl
        sqlite
        ffmpeg
      ];
    in
    {
      systemd.services.stash = {
        description = "Stash daemon";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        environment = {
          HOME = "%S/stash";
          STASH_GENERATED = "/var/lib/stash/generated";
          STASH_METADATA = "/var/lib/stash/metadata";
          STASH_CACHE = "/var/lib/stash/cache";
          STASH_CONFIG_FILE = "/var/lib/stash/config.yml";
          STASH_HOST = cfg.host;
          STASH_PORT = toString cfg.port;
          STASH_EXTERNAL_HOST = toString cfg.externalHost;
        };

        path = with pkgs; [
          (pkgs.python3.withPackages (ps: with ps; [
            cloudscraper
            configparser
            progressbar
            requests
          ]))
          bashInteractive
          openssl
          sqlite
          ffmpeg
        ];

        preStart = ''
          # mkdir -p ~/.stash && chmod 0700 ~/.stash
          ln -sf ${pkgs.ffmpeg}/bin/ffmpeg /var/lib/stash/ffmpeg
          ln -sf ${pkgs.ffmpeg}/bin/ffprobe /var/lib/stash/ffprobe
        '';

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          # DynamicUser = true;
          User = cfg.user;
          Group = cfg.group;
          StateDirectory = "stash";
          ExecStart = "${flake.packages.stash}/bin/stash --nobrowser";
        };
      };

      users.users = mkMerge [
        (mkIf (cfg.user == "stash") {
          stash = {
            isSystemUser = true;
            group = cfg.group;
            home = cfg.dataDir;
            createHome = true;
          };
        })
        (attrsets.setAttrByPath [ cfg.user "packages" ] ([ flake.packages.stash ] ++ stashPackages))
      ];

      users.groups = optionalAttrs (cfg.group == "stash") {
        stash = { };
      };
    }
  );
}
