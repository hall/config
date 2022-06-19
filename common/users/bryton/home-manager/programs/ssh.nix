{ flake, ... }:
let
  # get ssh key from bitwarden
  ssh-key = x: builtins.toFile "${x}-ssh-key" (
    flake.lib.pass "--folder ssh ${x}"
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
      identityFile = ssh-key "pinephone";
    };
    osmc = {
      user = "osmc";
      identityFile = ssh-key "github";
    };
    pi = {
      host = "bedroom office tv";
      user = flake.username;
      identityFile = ssh-key "pi";
    };

    rigetti = {
      host = "rigetti.gitlab.com";
      hostname = "gitlab.com";
      user = "git";
      identityFile = ssh-key "rigetti";
    };
  };
}
