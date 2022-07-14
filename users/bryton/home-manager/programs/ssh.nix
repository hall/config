{ flake, ... }:
let
  # get ssh key from bitwarden
  ssh-key = x: flake.lib.pass {
    name = "${x}";
    args = "--folder ssh";
  };
in
{
  enable = true;
  extraOptionOverrides = {
    CanonicalizeHostname = "yes";
    CanonicalDomains = "lab.rigetti.com";
  };
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
      host = "bedroom office tv k0 x12";
      user = flake.username;
      identityFile = ssh-key "pi";
    };

    rigetti = {
      host = "rigetti.gitlab.com";
      hostname = "gitlab.com";
      user = "git";
      identityFile = ssh-key "rigetti";
    };
    lab = {
      host = "*.lab.rigetti.com";
      user = "ansible";
      identityFile = "~/.ssh/infra-shared.pem";
      extraOptions = {
        PubkeyAcceptedKeyTypes = "+ssh-ed25519";
      };
    };
  };
}
