{ pkgs, ... }:
{
  networking = {
    # wireless.enable = true;
    networkmanager.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_5_19;
    # extraModulePackages = with config.boot.kernelPackages; [ wireguard ];
    #extraModprobeConfig = ''
    #  options snd-intel-dspcfg dsp_driver=3
    #'';
  };
  imports = [ ./hardware.nix ];
}
