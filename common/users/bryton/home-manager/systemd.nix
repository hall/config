{ pkgs, ... }:
{
  user = {
    startServices = "sd-switch";
    services = {
      gotify-desktop = {
        Unit = {
          Description = "Gotify Desktop";
          After = "network.target";
        };
        Service = {
          ExecStart = "${pkgs.gotify-desktop}/bin/gotify-desktop";
        };
        Install = {
          WantedBy = [ "graphical.target" ];
        };
      };
    };
  };
}
