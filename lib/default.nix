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
  loadModules = import ./loadModules.nix;
  readDirNames = import ./readDirNames.nix;
  mkHosts = import ./mkHosts.nix;

  pass = x: doas "rbw get ${x}";
}
