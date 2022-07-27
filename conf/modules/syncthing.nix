{ flake, lib, config, ... }:
let
  home = config.users.users.${flake.username}.home;

  # device groups
  personal = [ "x12" "pinephone" ];
  work = [ "rigetti" ];
  all = personal ++ work;

  # true if current host is in `group`
  inGroup = group: (builtins.elem config.networking.hostName group);
in
{
  services = {
    syncthing = {
      enable = inGroup all;
      user = flake.username;
      dataDir = home;
      devices = {
        x12.id = "FXVXWO2-GRRKEDH-3R6ZP3V-PPUYUTM-6FFHCNR-3YYRFJU-QOUHAMG-X27JJQB";
        rigetti.id = "B5FZE7E-6HH43KW-BC2EI3A-FMORTYY-TOKOM66-Z7G5KX6-R4IIJXL-ULN6KQL";
        pinephone.id = "NMTAKR7-KYODQLF-OFSZYNW-LCPHLRX-WNEX2IJ-LMFD5G2-TEMNVLB-SGK4ZQV";
      };
      folders = {
        notes = {
          path = "${home}/notes";
          devices = all;
        };
      } // (lib.mkIf (inGroup personal)
        (builtins.listToAttrs (map
          (dir: {
            name = dir;
            value = {
              path = "${home}/${dir}";
              devices = personal;
            };
          })
          [ "cloud" "library" "sessions" ".stash" ]
        )))
      ;
    };
  };
}
