{ config, pkgs, flake, lib, ... }:
{
  accounts = import ./accounts.nix { inherit flake; };
  dconf = import ./dconf.nix;
  gtk = import ./gtk.nix pkgs;
  programs = import ./programs { inherit pkgs flake; };
  services = import ./services.nix;
  systemd = import ./systemd.nix pkgs;
  xdg = import ./xdg.nix pkgs;

  home = {
    username = flake.username;
    homeDirectory = "/home/${flake.username}";
    # https://nix-community.github.io/home-manager/release-notes.html#sec-release-22.05
    stateVersion = "22.05";
    packages = import ./packages.nix { inherit config pkgs flake lib; };
    sessionVariables = {
      CALIBRE_USE_DARK_PALETTE = "1";
    };
    file = let path = ../stage; in
      builtins.listToAttrs
        (map
          (file:
            let
              # get relative filename
              filename = lib.strings.removePrefix "${(builtins.toString path)}/" (builtins.toString file);
            in
            {
              name = filename;
              value = {
                source = path + "/${filename}";
                target = filename;
              };
            })
          (lib.filesystem.listFilesRecursive path)
        );
  };
}
 
