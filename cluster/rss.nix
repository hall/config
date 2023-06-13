{ kubenix, ... }: {
  submodules.instances.freshrss = {
    submodule = "release";
    args = {
      enable = true;
      image = "linuxserver/freshrss:1.20.1";
      host = "rss";
      port = 80;
      persistence.config.enabled = true;
    };
  };
}
