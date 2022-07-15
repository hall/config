{ pkgs, flake, ... }:
let
  script = let path = "/run/secrets"; in
    (pkgs.writeScript "pass"
      ''
        #!${pkgs.bash}/bin/bash
        if [ ! -f ${path } ]; then
          mkdir -p ${path}
          chmod 700 ${path}
          chown ${flake.username} ${path}
          setfacl -d --set u::r ${path}
        fi

        # parse name from remaining args
        read -ra arr <<<"$*"
        name=''${arr[0]}
        args="''${arr[@]:1}"

        su -c "rbw get $args $name" $(logname) | tee ${path}/$name > /dev/null
        chown ${flake.username} ${path}/$name

        # return strigified path to secret
        echo \"${path}/$name\"
      '');

in
rec {
  pass = name: builtins.exec [ script name ];

  mkHosts = import ./mkHosts.nix { inherit readDirNames; };

  readDirNames = path:
    let
      files = builtins.readDir path;
      isDirectory = name: files."${name}" == "directory";
    in
    builtins.filter isDirectory (builtins.attrNames files);
}
