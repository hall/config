{ config, lib, ... }: {
  age.secrets = {
    restic.rekeyFile = ./restic.age;
    gcp.rekeyFile = ./gcp.age;
  };

  systemd.services.restic-backups-remote.environment = {
    GOOGLE_PROJECT_ID = "practical-ring-398523";
    GOOGLE_APPLICATION_CREDENTIALS = config.age.secrets.gcp.path;
  };

  # manually trigger with: `systemctl start restic-backups-remote`
  services.restic.backups.remote = {
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
    paths = (lib.mapAttrsToList (name: folder: folder.path) config.services.syncthing.settings.folders) ++ [
      "/var/lib/media"
      "/var/lib/kodi"
      "/var/lib/sonarr"
      "/var/lib/radarr"
      "/var/lib/lidarr"
      "/var/lib/prowlarr"
      "/var/lib/jellyfin"
      "/var/lib/jellyseerr"
      "/var/lib/postgresql"
    ];
  };
}
