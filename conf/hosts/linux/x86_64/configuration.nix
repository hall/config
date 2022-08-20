{ ... }:
{
  networking = {
    # wireless.enable = true;
    networkmanager.enable = true;
  };

  imports = [ ./hardware.nix ];
}
