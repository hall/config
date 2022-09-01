{ pkgs, flake, ... }:
{
  imports = [
    flake.inputs.home.nixosModules.home-manager
  ];

  hardware = {
    pulseaudio.enable = false;
    i2c.enable = true;
    sensor.iio.enable = true;
  };

  console = {
    useXkbConfig = true;
  };

  services = {
    # printing.enable = true;
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
        users = [ flake.username ];
        commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
      }
    ];
    rtkit.enable = true;
  };

  users.users = {
    ${flake.username} = {
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/nxzI9MwJC1gMWCNDzdGUZsRvsCdNBqaH5iJwreqHc" # /secrets/id_ed25519.age
      ];
    };
  };
}
