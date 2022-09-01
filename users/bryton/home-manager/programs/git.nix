{ flake }:
{
  enable = true;
  userName = flake.name;
  userEmail = flake.email;
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
