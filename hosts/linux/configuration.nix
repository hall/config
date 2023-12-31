{ pkgs, flake, modulesPath, ... }: {

  # don't wait to pick a boot entry (press enter to activate prompt)
  boot.loader.timeout = 1; # TODO: 0 waits forever?
  hardware = {
    pulseaudio.enable = false;
    i2c.enable = true; # TODO: move?
  };

  console = {
    useXkbConfig = true;
  };

  services = {
    # avahi = {
    #   enable = true;
    #   nssmdns = true;
    # };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  security = {
    sudo.extraRules = [
      {
        users = [ flake.lib.username ];
        commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
      }
    ];
    rtkit.enable = true;
  };

  users.users = {
    ${flake.lib.username} = {
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/nxzI9MwJC1gMWCNDzdGUZsRvsCdNBqaH5iJwreqHc" # /secrets/id_ed25519.age
      ];
    };
  };
}
