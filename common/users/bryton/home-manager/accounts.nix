{
  email = {
    accounts = {
      personal = {
        address = "email@bryton.io";
        realName = "Bryton Hall";
        primary = true;
        userName = "email@bryton.io";
        passwordCommand = "rbw get protonmail";
        imap = {
          host = "imap.bryton.io";
          port = 1143;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
        smtp = {
          host = "smtp.bryton.io";
          port = 1025;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
      };
    };
  };
}
