{ pkgs, ... }:
{
  # TODO: how to enable?
  user.services = {
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
}
