{ config, lib, pkgs, flake, ... }: {
  # mergeable list of unfree packages (per-host additions append to this)
  options.allowedUnfree = lib.mkOption {
    type = with lib.types; listOf str;
    default = [ ];
  };

  config = {
    allowedUnfree = [
      "obsidian"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "vscode"
      "claude-code"
      "vscode-extension-anthropic-claude-code"
    ];
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.allowedUnfree;

    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
      optimise.automatic = true;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ flake.lib.username ];
        substituters = [ "https://nix-community.cachix.org" ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
  };
}
