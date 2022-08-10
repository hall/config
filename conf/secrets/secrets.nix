let
  # for manual re-encryption/rotation; backup in bitwarden
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/nxzI9MwJC1gMWCNDzdGUZsRvsCdNBqaH5iJwreqHc";

  members = hosts: builtins.attrValues hosts;

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
    tv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKNiXlHRZyKrVEfnMHnCTboWctumTRih80NHOVFog8bn";
    x12 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP70uIe/+6FtPWkuA7qiNRAoe2uvY+Qj/zGtU34HOccd";
    # pinephone = "ssh-ed25519 ";
  };

  # readDirNames = path:
  #   let
  #     files = builtins.readDir path;
  #     isDirectory = name: files."${name}" == "directory";
  #   in
  #   builtins.filter isDirectory (map (x: path + ./${x}) (builtins.attrNames files));

  # # hosts = readDirNames ../hosts;
  # arches = builtins.concatMap (x: readDirNames ./hosts/${x}) (readDirNames ./hosts);
in
{
  # for ssh-ing to hosts
  "id_ed25519.age".publicKeys = [ user ] ++ (members hosts) ++ (members cluster);
  # for openwrt
  # ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcBJM2XkhTGCFCKlXbkQPD523PABGJtFdr+R2PkZtyImntKXXqgWo926fL4LKyBq+ZhfSIMLmqehz76bFrkg0UGqnQiBgH+EmbA2U6rc3yD8SzaWUalNkJtTK1Usf7ae6miXd3t9rn+0uZuu7633V6R0LZ7S+rza9rHVROSYNMik2sREoGiL++bwG/xBsWMF5qCMo5e6XW8Qe5rLbDU9AhrwyNfrE1m9WQ+X3ISlosbbMQiLJVChQImFIYwQ8RBAUUKkNZx2gRRXzQqRKZCkSB8SzAQnFD2ljKQB0A+dVQv76bmg2Gb/XjCTk9NYbgYFGIc+XCVljllj90C+RP10lI19ep7rvziJaQsleKry+vk2ciYY2ROBEmEyDPeTdXYCllkZXA0c5yAXKuilnz1IxgGcDeWB9ekMV5uVS/fg3W0DGJINC8XXlReoQM91qJGd40YACG3KeuBv4xcpG09Ou51KHPPslvL9cymHxVuADS5JxwSXG41MjKdBKGcoLKth8=
  "id_rsa.age".publicKeys = with hosts; [ user x12 ];

  # 3rd party providers
  "github.age".publicKeys = with hosts; [ user x12 ];
  "gitlab.age".publicKeys = with hosts; [ user x12 ];
  "nixbuild.age".publicKeys = with hosts; [ user x12 ];

  # k3s node token
  "k3s.age".publicKeys = [ user ] ++ (members cluster);

  # password for librespot
  # "spotify.age".publicKeys = with hosts; [ user old office ];
}
