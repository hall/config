{ flake }:
{
  email = {
    accounts = {
      personal = {
        address = flake.email;
        realName = flake.name;
        primary = true;
        userName = flake.email;
        passwordCommand = "rbw get protonmail";
        imap = {
          host = "imap.${flake.hostname}";
          port = 1143;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
        smtp = {
          host = "smtp.${flake.hostname}";
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
