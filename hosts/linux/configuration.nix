{ flake, lib, ... }: {
  monitoring.enable = true;

  # don't wait to pick a boot entry (press enter to activate prompt)
  boot.loader.timeout = lib.mkForce 0; # TODO: 0 waits forever?
  hardware = {
    i2c.enable = true; # TODO: move?
  };

  console.useXkbConfig = true;

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # jack.enable = true;
    };
  };

  age.secrets = {
    luks = {
      rekeyFile = ./luks.age;
      owner = flake.lib.username;
    };
    grafana = {
      rekeyFile = ./grafana.age;
      owner = flake.lib.username;
    };
  };

  security = {
    polkit.enable = true;
    pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      swaylock = { };
    };
    rtkit.enable = true;
    sudo.extraRules = [{
      users = [ flake.lib.username ];
      commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
    }];
  };

}
