let
  # for manual re-encryption/rotation; backup in bitwarden
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/nxzI9MwJC1gMWCNDzdGUZsRvsCdNBqaH5iJwreqHc";

  # get all members in a group
  members = group: builtins.attrValues group;

  cluster = {
    k0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkFWJeyK4IKGYcoLeBRH/iBoL75EgzII5saY5tABf7m";
    k1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkGuYopkxrbXIBRFnFTpMPSC2W4YNPFcfLt6SFTi6ce";
    k2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMmr6J1tAqfqkjEfLdB2KbOCJ2Okbudpb719G1Ext9n";
    k3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbZbcCFoFb82V/OCMpQqz2ttUKUCLcLY7ZckRIJnb8c";
    k4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGZnPCtMQxUVZN+NemLHpxrRWbMPNUyWG4tWXDN67j9S";
    office = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDjKBcUxKiTLaY3ag/A+p/CvOk7PtMDe+RDeq0ACsR+X";
  };

  hosts = {
    bedroom = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsgKixPi4ys95A03K5nTT18OiMAXD9POq/EvnyDnznN";
    pinephone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHx6N0eSzOMJF9fa2WjftMedXnpCQvuSXCdaPsl63T1";
    router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGh1Y9bVrHzswsKNXJIVefURm345gH0X1Tx1edzY617h";
    tv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBsVhSyPX8F3/WBo+W9w8lYAtfnFgQGg7k7w/8SINCa";
    x12 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP70uIe/+6FtPWkuA7qiNRAoe2uvY+Qj/zGtU34HOccd";
  };

  work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl/FhVda1Cr2CMOpvr67C4F3n9Fw07oAL7SorUAZdbl";

  main = [ user hosts.x12 ];
in
{
  # for ssh-ing to hosts
  "id_ed25519.age".publicKeys = main;
  # for hosts w/o ed25519 support, e.g., openwrt
  "id_rsa.age".publicKeys = main;

  # for work accounts/devices
  "id_work.age".publicKeys = [ user work ];

  # 3rd party providers
  "github.age".publicKeys = main;
  "gitlab.age".publicKeys = main;
  "nixbuild.age".publicKeys = main;

  # k3s node token
  "k3s.age".publicKeys = [ user ] ++ (members cluster);

  # password for librespot
  "spotify.age".publicKeys = with hosts; [ user bedroom ];

  # kubernetes
  "kubeconfig.age".publicKeys = main;
  "kubenix.age".publicKeys = main;

  # wireguard
  "wg_router.age".publicKeys = main ++ [ hosts.router ];
  "wg_x12.age".publicKeys = main ++ [ hosts.x12 ];
}
