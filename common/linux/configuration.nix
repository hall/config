{ pkgs, system, inputs, flake, flakePkgs, ... }:
{
  # environment = {
  #   systemPackages = with pkgs; [
  #   ];
  # };

  hardware = {
    pulseaudio.enable = false;
    i2c.enable = true;
    sensor.iio.enable = true;
  };

  console = {
    useXkbConfig = true;
  };

  services = {
    printing.enable = true;
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

  sound.enable = true;

  security = {
    sudo.extraRules = [
      {
        users = [ flake.username ];
        commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
      }
    ];
    rtkit.enable = true;
  };
}
