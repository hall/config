{ flake, ... }:
{
  services = {
    openssh = {
      enable = true;
      # passwordAuthentication = false;
      # permitRootLogin = "no";
      # allowSFTP = false;
    };
  };

  users.users = {
    ${flake.username} = {
      isNormalUser = true;
      initialPassword = "1234";
      group = "users";
      # openssh.authorizedKeys.keys = [ (flake.lib.pass "--full pi | grep pub: | awk '{print $2}'") ];
    };
  };
}
