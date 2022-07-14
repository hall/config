let
  # like exec but not as the root user (also, return a string)
  doas = x: builtins.exec [
    "su"
    "-c"
    "echo \"''\" && ${x} && echo \"''\""
    (builtins.exec [ "sh" "-c" "echo \"''$(logname)''\"" ])
  ];
in
{
  pass = let path = "/run/secrets"; in
    { name, args ? "" }:
    if (doas "sudo mkdir -p ${path} && sudo chmod 700 ${path}; sudo chown bryton ${path}; sudo setfacl -d --set u::r ${path}; rbw get ${args} ${name} | sudo tee ${path}/${name} > /dev/null; sudo chown bryton ${path}/${name}"
    ) == "" then "${path}/${name}" else "";

  mkHosts = import ./mkHosts.nix;

  readDirNames = path:
    let
      files = builtins.readDir path;
      isDirectory = name: files."${name}" == "directory";
    in
    builtins.filter isDirectory (builtins.attrNames files);
}
