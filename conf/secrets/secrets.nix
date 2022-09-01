let
  # for manual re-encryption/rotation; backup in bitwarden
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/nxzI9MwJC1gMWCNDzdGUZsRvsCdNBqaH5iJwreqHc";

  # get all members in a group
  members = group: builtins.attrValues group;

  cluster = {
    k0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVGaaL/HIr/0HdaqSoZ4giMzqBEpZ/eWBwD6ct0lB2K";
    k1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQIAo8GyvynexxqaeUlkQPjqnU9Ky5gRr6Ut83XJhpy";
    k2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBT90Iw3wAsrb7asEcxY3RamKZxTIr1Gs2ZyBsxgg7z";
    k3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqea9Z97QRtRfJbKTFhrTEmOuFmvh0TigPwl48I6U6f";
    k4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlhRKiWNygfTCtYAnS8X608At0MHF8Og1TDaFLjcEX0";
    # k5 = "ssh-ed25519 ";
  };

  hosts = {
    bedroom = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFjdkSO9y85QQ0n6bmXI2RJLVYBsEVMPLtRoFCVHk39";
    office = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNhknXC4pUYgz1eU1FNgpuy/zPIxaH9Rh5MP4+7Qku0";
    pinephone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHx6N0eSzOMJF9fa2WjftMedXnpCQvuSXCdaPsl63T1";
    tv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBsVhSyPX8F3/WBo+W9w8lYAtfnFgQGg7k7w/8SINCa";
    x12 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP70uIe/+6FtPWkuA7qiNRAoe2uvY+Qj/zGtU34HOccd";
  };

  work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl/FhVda1Cr2CMOpvr67C4F3n9Fw07oAL7SorUAZdbl";

  # readDirNames = path:
  #   let
  #     files = builtins.readDir path;
  #     isDirectory = name: files."${name}" == "directory";
  #   in
  #   builtins.filter isDirectory (map (x: path + ./${x}) (builtins.attrNames files));

  # # hosts = readDirNames ../hosts;
  # arches = builtins.concatMap (x: readDirNames ./hosts/${x}) (readDirNames ./hosts);

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
  "spotify.age".publicKeys = with hosts; [ user office ];

  # kubernetes
  "kubeconfig.age".publicKeys = main;
}
