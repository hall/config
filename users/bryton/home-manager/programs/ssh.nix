{ flake, ... }:
{
  enable = true;
  matchBlocks = {
    # not (yet?) managed by nix
    devices = {
      host = "router switch ap1 ap2";
      user = "root";

      # ap2 needs these, dropbear is too old, I guess
      extraOptions = {
        PubkeyAcceptedKeyTypes = "+ssh-rsa";
        HostKeyAlgorithms = "+ssh-rsa";
      };
    };

    old = {
      host = "office";
      identityFile = "/home/bryton/.ssh/backup/pi";
    };

    gitlab = {
      host = "gitlab.com";
      user = "git";
      identityFile = "/run/secrets/gitlab";
    };
    github = {
      host = "github.com";
      user = "git";
      identityFile = "/run/secrets/github";
    };

  };
}
