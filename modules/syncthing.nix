{ flake, lib, config, ... }:
let
  home = "/home/${flake.username}";

  # device groups
  personal = [ "x12" "pinephone" ];
  work = [ "rigetti" ];
  all = personal ++ work;
in
{
  services = {
    syncthing = {
      enable = true;
      user = flake.username;
      dataDir = home;
      devices = {
        x12.id = "FXVXWO2-GRRKEDH-3R6ZP3V-PPUYUTM-6FFHCNR-3YYRFJU-QOUHAMG-X27JJQB";
        rigetti.id = "B5FZE7E-6HH43KW-BC2EI3A-FMORTYY-TOKOM66-Z7G5KX6-R4IIJXL-ULN6KQL";
        pinephone.id = "NMTAKR7-KYODQLF-OFSZYNW-LCPHLRX-WNEX2IJ-LMFD5G2-TEMNVLB-SGK4ZQV";
      };
      folders = lib.mkMerge [
        {
          notes = {
            path = "${home}/notes";
            devices = all;
          };
        }
        (lib.mkIf (builtins.elem config.networking.hostName personal) {
          guitarix = {
            path = "${home}/.config/guitarix";
            devices = personal;
          };
          library = {
            path = "${home}/library";
            devices = personal;
          };
        })
      ];
    };
  };
}
