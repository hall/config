{ pkgs, ... }:
{
  user.services = {
    gotify-desktop = {
      Unit = {
        Description = "Gotify Desktop";
        After = "network.target";
      };
      Service = {
        ExecStart = "${pkgs.unstable.gotify-desktop}/bin/gotify-desktop";
      };
      Install = {
        WantedBy = ["graphical.target"];
      };
    };
  };
}
