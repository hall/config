{ flake, lib, config, ... }:
let
  ids = {
    laptop = "FXVXWO2-GRRKEDH-3R6ZP3V-PPUYUTM-6FFHCNR-3YYRFJU-QOUHAMG-X27JJQB";
    phone = "LGVEZX6-TYKLGEY-JJWU3ND-Y7TWKWX-U4FHOAG-MY2PK3J-3YQW3HI-BYADJAX";
    server = "QYLMEYI-BN5XJTZ-JQOMEGQ-TSGKWUA-6L3UN62-RRZ6QSM-6TGY4VM-3EOL5AU";
    work = "Y3NZ6BJ-6V4NGYM-CBL63XV-EE67Y4A-AYL2ZTI-MIUWRH6-TIEKFPS-AVR5HQ5";
  };

  # only share with those in your group (names are arbitrary)
  groups = {
    personal = {
      devices = [ "laptop" "phone" "server" ];
      folders = [ "drawings" "notes" "library" "sessions" "stash" ];
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
