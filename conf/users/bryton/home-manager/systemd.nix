{ pkgs, ... }:
{
  user = {
    startServices = "sd-switch";
    services = {
      # NAME = {
      #   Unit = {
      #     Description = "";
      #     After = "network.target";
      #   };
      #   Service = {
      #     ExecStart = "${pkgs.NAME}/bin/NAME";
      #   };
      #   Install = {
      #     WantedBy = [ "graphical.target" ];
      #   };
      # };
    };
  };
}
