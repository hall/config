{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      globalprotect-openconnect
    ];
  };

  networking = {
    # firewall = {
    #   allowedTCPPorts = [
    #   ];
    # };
  };

  services = {
    globalprotect = {
      enable = true;
    };
  };

}
