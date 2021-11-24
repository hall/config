{
  email = {
    accounts = {
      personal = {
        address = "email@bryton.io";
        realName = "Bryton Hall";
        primary = true;
        userName = "email@bryton.io";
        passwordCommand = "bw get password protonmail";
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
          port = 1120;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
      };
    };
  };
}
