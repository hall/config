{ config, pkgs, lib, ... }: {
  age.secrets = {
    restic.rekeyFile = ./restic.age;
    gcp = {
      rekeyFile = ./gcp.age;
      # group = config.services.prometheus.exporters.restic.group;
    };
  };

  systemd.services =
    let
      env = {
        GOOGLE_PROJECT_ID = "practical-ring-398523";
        GOOGLE_APPLICATION_CREDENTIALS = config.age.secrets.gcp.path;
      };
    in
    {
      restic-backups-remote.environment = env;
      prometheus-restic-exporter.environment = env;
    };

  services = {
    # manually trigger with: `systemctl start restic-backups-remote`
    restic.backups.remote = {
      repository = "gs:hall-backups:/";
      initialize = true;
      passwordFile = config.age.secrets.restic.path;
      # timerConfig.OnCalendar = "sunday 23:00";
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
        "--keep-yearly 1"
      ];
      # TODO: manually update /persist
      paths = (builtins.filter (x: x != "/var/lib/stash") (lib.mapAttrsToList (name: folder: folder.path) config.services.syncthing.settings.folders)) ++ [
        "/var/lib/media/books"
        "/var/lib/media/music"
        "/var/lib/media/movies"
        "/var/lib/media/shows"
        "/var/lib/private/kodi"
        "/var/lib/sonarr"
        "/var/lib/radarr"
        "/var/lib/lidarr"
        "/var/lib/private/prowlarr"
        "/var/lib/jellyfin"
        "/var/lib/private/jellyseerr"
        "/var/lib/postgresql"
        "/etc/home-assistant"
      ];
    };
    prometheus.exporters = {
      restic = with config.services.restic.backups.remote; {
        enable = true;
        inherit repository passwordFile user;
      };
    };
  };
}
