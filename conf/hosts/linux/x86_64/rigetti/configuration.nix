{ pkgs, flake, ... }:
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

  age.secrets.id_work = {
    file = ../../../../secrets/id_work.age;
    owner = flake.username;
  };
}
