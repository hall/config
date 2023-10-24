let
  # for manual re-encryption/rotation; backup in bitwarden
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/nxzI9MwJC1gMWCNDzdGUZsRvsCdNBqaH5iJwreqHc";

  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBsVhSyPX8F3/WBo+W9w8lYAtfnFgQGg7k7w/8SINCa";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP70uIe/+6FtPWkuA7qiNRAoe2uvY+Qj/zGtU34HOccd";
  work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl/FhVda1Cr2CMOpvr67C4F3n9Fw07oAL7SorUAZdbl";

  main = [ user laptop ];
in
{
  # for ssh-ing to hosts
  "id_ed25519.age".publicKeys = main;

  # for work accounts/devices
  "id_work.age".publicKeys = [ user work ];

  # 3rd party providers
  "github.age".publicKeys = main;
  "gitlab.age".publicKeys = main;

  "wifi.age".publicKeys = main ++ [ server work ];

  # acme DNS validation
  "namecheap.age".publicKeys = main ++ [ server ];
}
