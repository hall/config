{
  tree = {
    root = "src-test";
    repos = [
      { url = https://github.com/nix-community/home-manager; }
      {
        url = https://github.com/my-own-personal/NUR;
        remotes = [
          {
            name = "upstream";
            url = https://github.com/nix-community/NUR;
          }
        ];
      }
    ];
  };
}
