{ flake, ... }:
{
  services.k3s = {
    enable = true;
    role = "server";
  };
}
