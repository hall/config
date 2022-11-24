{ kubenix, vars, ... }:
vars.simple {
  inherit kubenix;
  image = "linuxserver/freshrss:1.20.1";
  host = "rss";
  port = 80;
  persistence.config.enabled = true;
}
