{ config, pkgs, ... }:
let
  cfg = config.services.git;
  repoOptions = {
    name = mkOption {
      type = types.str;
      default = "";
      description = "Name of git remote.";
    };
    url = mkOption {
      type = types.url;
      description = "git URL.";
    };
  };
in
{
  options.services.git = {
    root = mkOption {
      type = types.str;
      default = "src";
      description = ''
        Root directory where git repos will be managed, relative to the user's home.
      '';
    };

    repos = mkOption {
      type = types.listOf (submodule {
        options = repoOptions + {
          remotes = mkOption {
            type = types.listOf (submodule {
              options = repoOptions;
            });
          };
        };
      });
    };
  };
  config = { };
}
