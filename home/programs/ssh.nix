{...}:
let
  # get ssh key from bitwarden
  ssh-key = x: builtins.toFile "${x}-ssh-key" (
    builtins.exec [
      "su"
      "-c"
      "echo \"''\" && rbw get --folder ssh ${x} && echo \"''\""
      "-"
      "bryton"
    ]
  );
in
{
  enable = true;
  matchBlocks = {
    gitlab = {
      host = "gitlab.com";
      user = "git";
      identityFile = ssh-key "gitlab";
    };
    github = {
      host = "github.com";
      user = "git";
      identityFile = ssh-key "github";
    };
    devices = {
      host = "router switch ap1 ap2";
      user = "root";
      identityFile = ssh-key "router";
    };
    pinephone = {
      host = "pinephone";
      identityFile = ssh-key "pinephone";
    };
    osmc = {
      host = "osmc";
      user = "osmc";
      identityFile = ssh-key "github";
    };
  };
}
