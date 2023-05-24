{ flake }:
{
  email = {
    accounts = {
      personal = {
        address = flake.lib.email;
        realName = flake.lib.name;
        primary = true;
        userName = flake.lib.email;
        passwordCommand = "rbw get protonmail";
        imap = {
          host = "imap.${flake.lib.hostname}";
          port = 1143;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
        smtp = {
          host = "smtp.${flake.lib.hostname}";
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
