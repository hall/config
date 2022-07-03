{ flake, ... }:
{
  imports = [
    # "${flake.inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

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
      extraGroups = [ "wheel" ];
      # openssh.authorizedKeys.keys = [ (flake.lib.pass "--full pi | grep pub: | awk '{print $2}' | tr -d '\n'") ];
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNum8zhcXBArQqAHmcU9bT6LZ84oPMSJFG7OcE4KS2Sby9HLcDMcTJ+35YzQ3kYqqnZwGH2/KS6AGu5VGzQ/zGYlm2xbFVGX9PHBzx3A7jaoH/EEm+491vzwh6lxNcmPW2OPRp+j5UOajX5kNmLB5eHIxGuANp75lgfD8uJwbB13rMjcinbQvcabM1hVHN4lQIgeFH3G+txv0be+p5pYh02iIT5JKXv6qT4odyItNuZKPl4ZuAcLSTqpvkvAgkxmPngWGJrGFtHM8r06+KQ5JTXx9m5/uuT/1zOJjn2mBclwcm4JWcAcCrc2pqr2U8fELDi0MWnOxB+hR/p7/hAbzdWbr9S8anBHZoXDBVyUZ7z7yqRAVNGcqANGkzkFwVpxjkzX6rqdA8bAPUvgJZDMMVYB8U5In9vJCLTdjbda9bE7jGWlQKU3A3jEIrm1OGxQCWQtgzjQHDuK/VbkxbdfQbDS1e4XSwxM8AAxUytIXiyIgbFa/rMZp/exWBjBL1I5k= bryton@x12" ];
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/126755
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
}
