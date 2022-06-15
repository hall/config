{
  enable = true;
  userName = "Bryton Hall";
  userEmail = "email@bryton.io";
  difftastic.enable = true;
  extraConfig = {
    init = {
      defaultBranch = "main";
    };
    url = {
      "git@gitlab.com:" = {
        insteadOf = "https://gitlab.com/";
      };
    };
    pull = {
      rebase = false;
    };
  };
  includes = [
    {
      condition = "gitdir:~/src/gitlab.com/rigetti/";
      contents = {
        user = {
          email = "bhall@rigetti.com";
        };
        url = {
          "rigetti.gitlab.com" = {
            insteadOf = "gitlab.com";
          };
        };
      };
    }
  ];
}
