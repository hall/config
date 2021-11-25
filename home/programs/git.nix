{
  enable = true;
  userName = "Bryton Hall";
  userEmail = "email@bryton.io";
  extraConfig = {
    init = {
      defaultBranch = "main";
    };
    url = {
      "git@gitlab.com:" = {
        insteadOf = "https://gitlab.com/";
      };
    };
  };
}
