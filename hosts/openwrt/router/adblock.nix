_: {
  packages = [ "luci-app-adblock" ];

  etc = {
    "adblock/adblock.allowlist".text = ''
      stats.grafana.org
    '';
    "adblock-heal.sh".text = builtins.readFile ./adblock-heal.sh;
    # keep the script and the last good blocklist across sysupgrades
    "sysupgrade.conf".text = ''
      ## This file contains files and directories that should
      ## be preserved during an upgrade.

      /etc/adblock-heal.sh
      /etc/adblock-backup/
    '';
    # dewclaw can't set modes (new files are 0644), so call the script via sh
    "crontabs/root".text = ''
      */15 * * * * sh /etc/adblock-heal.sh
      30 4 * * * /etc/init.d/adblock reload
    '';
  };

  uci.settings.adblock.adblock.global = {
    adb_enabled = true;
    adb_debug = false;
    adb_safesearch = false;
    adb_mail = false;
    adb_report = true;
    # clients (e.g. Android Private DNS) bypass the blocklist with their own
    # resolvers: redirect plain DNS to dnsmasq and reject DoT
    adb_nftforce = true;
    adb_nftdevforce = [ "br-lan" ];
    adb_nftportforce = [
      "53"
      "853"
    ];
    adb_dns = "dnsmasq";
    adb_fetchcmd = "uclient-fetch";
    adb_trigger = [
      "wan"
      "wan6"
    ];
    adb_triggerdelay = 30;
    adb_nicelimit = 0;
    adb_nftallow = false;
    adb_nftblock = false;
    adb_nftremote = false;
    adb_nftbridge = false;
    adb_dnsinstance = 0;
    adb_repiface = "br-lan";
    adb_feed = "hagezi";
    # doh: DoH runs over 443, so block its resolver hostnames instead
    adb_hag_feed = [
      "wildcard/pro-onlydomains.txt"
      "wildcard/doh-onlydomains.txt"
    ];
    adb_fetchretry = 5;
    adb_backupdir = "/etc/adblock-backup";
  };
}
