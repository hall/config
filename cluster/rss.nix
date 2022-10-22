{ kubenix, vars, ... }:
vars.simple {
  inherit kubenix;
  image = "freshrss/freshrss:1.20.0-arm";
  host = "rss";
  port = 80;
  persistence.config.mountPath = "/var/www/FreshRss/data";
}
