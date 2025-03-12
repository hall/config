{ config, lib, pkgs, flake, ... }: {
  age.secrets.nextcloud = {
    rekeyFile = ./nextcloud.age;
    owner = config.services.nextcloud.config.dbuser;
  };
  age.secrets.postgresql-nextcloud = {
    rekeyFile = ./postgresql.age;
    owner = config.services.nextcloud.config.dbuser;
  };

  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      https = true;
      hostName = "cloud.${flake.lib.hostname}";
      configureRedis = true;
      # TODO: increase?Redis
      maxUploadSize = "1G";
      # phpExtraExtensions = all: with all; [ php-systemd ];

      config = {
        adminuser = "hall";
        adminpassFile = config.age.secrets.nextcloud.path;

        dbtype = "pgsql";
        dbhost = "localhost:5432";
        dbpassFile = config.age.secrets.postgresql-nextcloud.path;
      };

      settings = {
        mail_smtpmode = "sendmail";
        mail_sendmailmode = "pipe";
        # this allows logs to be viewed in the UI
        # plus, php-systemd (abandoned) is required for journal
        log_type = "file";
        # UTC hours between X, X + 4
        maintenance_window_start = 8;
        default_phone_region = "US";

        # opcache.memory_consumption = 256;
        "opcache.interned_strings_buffer" = 16;
        # opcache.max_accelerated_files = 32531;
        # opcache.validate_timestamps = 0;
        "opcache.jit" = 1255;
        "opcache.jit_buffer_size" = "8M";

        "memories.exiftool" = "${lib.getExe pkgs.exiftool}";
        "memories.vod.ffmpeg" = "${lib.getExe pkgs.ffmpeg-headless}";
        "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
      };

      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps)
          # bookmarks
          # cookbook
          # maps
          # mail
          # music
          calendar
          contacts
          # new
          notes
          tasks
          memories
          previewgenerator
          recognize
          ;
      };
    };

    nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
      useACMEHost = flake.lib.hostname;
      acmeRoot = null;
      forceSSL = true;
    };
  };
  systemd.services.nextcloud-cron = {
    path = [ pkgs.perl ];
  };
  environment.systemPackages = with pkgs;[
    # TODO: necessary for memories app?
    exiftool
    jellyfin-ffmpeg
    perl
  ];
}
