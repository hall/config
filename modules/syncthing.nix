{ flake, config, ... }:
let
  ids = {
    laptop = "PRAP2CM-Y5G32PN-37S5DF7-GJ3N536-BCGDPMS-3DHH7O2-KQXDCKQ-FY4WHAT";
    phone = "46G3FJN-GCQ62WO-UETUJCS-7TFXBY4-DJEJIT2-BAP36QE-BJVGC63-PCEPQQK";
    server = "EQVFF5C-GXNV2EP-IQRVWGC-YSQSFIP-5TRKGCD-FT4NKRC-LLRHCZK-SLXPWQW";
    work = "4AQBOHQ-3OYTLXQ-JTOT7VF-WG5GKF7-QHZDUTE-WAF5G7F-YG5HEOF-VHJ34AU";
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
