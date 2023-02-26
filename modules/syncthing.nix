{ flake, lib, config, ... }:
let
  ids = {
    x12 = "FXVXWO2-GRRKEDH-3R6ZP3V-PPUYUTM-6FFHCNR-3YYRFJU-QOUHAMG-X27JJQB";
    rigetti = "B5FZE7E-6HH43KW-BC2EI3A-FMORTYY-TOKOM66-Z7G5KX6-R4IIJXL-ULN6KQL";
    pinephone = "NMTAKR7-KYODQLF-OFSZYNW-LCPHLRX-WNEX2IJ-LMFD5G2-TEMNVLB-SGK4ZQV";
    server = "VHK4B2N-ISTNKQ5-PKSWYMN-OVFOIDF-EPC7DBG-GNTLB4J-ZHOU77D-JJB5YAW";
  };

  # only share with those in your group (names are arbitrary)
  groups = {
    personal = {
      devices = [ "x12" "pinephone" "server" ];
      folders = [ "notes" "cloud" "library" "sessions" ".stash" "photoprism" "paperless" ];
    };
    work = {
      devices = [ "rigetti" ];
      folders = [ "notes" ];
    };
  };

  home = config.users.users.${flake.username}.home;
  # all resources which contain the current host
  shared = resource: (builtins.concatMap (group: group.${resource}) (builtins.filter
    (group: builtins.elem config.networking.hostName group.devices)
    (builtins.attrValues groups)
  ));
in
{
  services = {
    syncthing = {
      # if host has an id
      enable = builtins.elem config.networking.hostName (builtins.attrNames ids);
      user = flake.username;
      openDefaultPorts = true;
      dataDir = home;
      devices = builtins.listToAttrs (builtins.map
        (device: {
          name = device;
          value.id = ids.${device};
        })
        (builtins.attrNames ids)
        # (shared "devices")
      );

      folders = builtins.listToAttrs (builtins.map
        (folder: {
          name = folder;
          value = {
            path = "${home}/${folder}";
            devices = builtins.concatMap (group: group.devices)
              (builtins.filter (group: builtins.elem folder group.folders)
                (builtins.attrValues groups));
          };
        })
        (shared "folders")
      );
    };
  };
}
