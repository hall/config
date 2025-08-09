{ lib, pkgs, flake, ... }: {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "obsidian"
    "onepassword-password-manager"
    "steam"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
    "vscode"
    "vscode-extension-github-copilot"
    "vscode-extension-github-copilot-chat"
    "vscode-extension-ms-toolsai-jupyter"
    "vscode-extension-ms-vscode-cpptools"
    "vscode-extension-ms-vscode-remote-remote-containers"
    "vscode-extension-ms-vsliveshare-vsliveshare"
    "windsurf"
  ];

  nix = {
    package = pkgs.nixVersions.latest;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    extraOptions = ''
      # https://github.com/nix-community/nix-direnv#installation
      keep-outputs = true
      keep-derivations = true
      # useful when builder has faster network
      builders-use-substitutes = true
    '';
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" flake.lib.username ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [
        "https://cache.nixos.org"
        "https://hydra.nixos.org"
        "https://nix-community.cachix.org"
      ];
    };

    distributedBuilds = true;
    buildMachines = with flake.nixosConfigurations.server.config; [{
      hostName = networking.hostName;
      # TODO: base64 encode
      # publicHostKey = age.rekey.hostPubkey;
      sshUser = flake.lib.username;
      # TODO: sshKey = config.age.secrets.id_ed25519.path;
      sshKey = "/home/${flake.lib.username}/.ssh/id_ed25519";
      # TODO: dynamically generate based on fs heirarchy
      systems = [ "x86_64-linux" ];
      maxJobs = 8;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }];
  };
}
