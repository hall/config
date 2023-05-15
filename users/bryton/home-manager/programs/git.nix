{ flake }:
{
  enable = true;
  userName = flake.lib.name;
  userEmail = flake.lib.email;
  # difftastic.enable = true;
  lfs.enable = true;
  extraConfig = {
    init = {
      defaultBranch = "main";
    };
    # url = {
    #   "git@gitlab.com:" = {
    #     insteadOf = "https://gitlab.com/";
    #   };
    # };
    pull = {
      rebase = false;
    };
  };
}
