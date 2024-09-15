{ flake, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.stash;
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

    environment = mkOption {
      type = types.attrs;
      default = { };
      description = mdDoc "Extra environment variables.";
      example = {
        STASH_EXTERNAL_HOST = "my.hostname";
      };
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/stash";
      description = mdDoc "Path where to store data files.";
    };
  };

  config = mkIf cfg.enable (
    let
      stashPackages = with pkgs; [
        (python3.withPackages (ps: with ps; [
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
    in
    {
      systemd.services.stash = {
        description = "Stash daemon";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = stashPackages;
        environment = {
          HOME = "%S/stash";
          STASH_GENERATED = "${cfg.dataDir}/generated";
          STASH_METADATA = "${cfg.dataDir}/metadata";
          STASH_CACHE = "${cfg.dataDir}/cache";
          STASH_CONFIG_FILE = "${cfg.dataDir}/config.yml";
          STASH_HOST = cfg.host;
          STASH_PORT = toString cfg.port;
        } // cfg.environment;

        preStart = ''
          # mkdir -p ~/.stash && chmod 0700 ~/.stash
          ln -sf ${pkgs.ffmpeg}/bin/ffmpeg ${cfg.dataDir}/ffmpeg
          ln -sf ${pkgs.ffmpeg}/bin/ffprobe ${cfg.dataDir}/ffprobe
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

      users = {
        users = mkIf (cfg.user == "stash") {
          stash = {
            isSystemUser = true;
            group = cfg.group;
            home = cfg.dataDir;
            createHome = true;
          };
        };

        groups = optionalAttrs (cfg.group == "stash") {
          stash = { };
        };
      };
    }
  );
}
