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
  pass = x: doas "rbw get ${x}";

  mkHosts = import ./mkHosts.nix;

  readDirNames = path:
    let
      files = builtins.readDir path;
      isDirectory = name: files."${name}" == "directory";
    in
    builtins.filter isDirectory (builtins.attrNames files);
}
