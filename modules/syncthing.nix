{ flake, lib, config, ... }:
let
  ids = {
    laptop = "FXVXWO2-GRRKEDH-3R6ZP3V-PPUYUTM-6FFHCNR-3YYRFJU-QOUHAMG-X27JJQB";
    phone = "B7BBARA-YRPNSSW-VN25256-2MXN64T-WS5BHBJ-RYF32XI-6KRH4FB-QP2DAQQ";
    server = "ANMYOD4-QYYMMN6-ZECPS5E-PM4F7BG-UUCBAVJ-QJS2R5C-5BMPN3W-HCLRSAB";
    work = "B5FZE7E-6HH43KW-BC2EI3A-FMORTYY-TOKOM66-Z7G5KX6-R4IIJXL-ULN6KQL";
  };

  # only share with those in your group (names are arbitrary)
  groups = {
    personal = {
      devices = [ "laptop" "server" ];
      folders = [ "notes" "cloud" "library" "sessions" ".stash" ];
    };
    mobile = {
      devices = [ "phone" ];
      folders = [ "notes" ];
    };
    work = {
      devices = [ "work" ];
      folders = [ "notes" ];
    };
  };

  home = config.users.users.${flake.lib.username}.home;
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
      user = flake.lib.username;
      openDefaultPorts = true;
      dataDir = home;

      settings = {
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
  };
}
