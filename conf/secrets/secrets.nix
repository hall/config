let
  hall = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAPZfm37xYNbJ90AHSe2+SeWhCpQ1sz1wFLEb9805ZW"; # github

  k0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVGaaL/HIr/0HdaqSoZ4giMzqBEpZ/eWBwD6ct0lB2K";
  k1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQIAo8GyvynexxqaeUlkQPjqnU9Ky5gRr6Ut83XJhpy";
  k2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBT90Iw3wAsrb7asEcxY3RamKZxTIr1Gs2ZyBsxgg7z";
  k3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqea9Z97QRtRfJbKTFhrTEmOuFmvh0TigPwl48I6U6f";
  k4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlhRKiWNygfTCtYAnS8X608At0MHF8Og1TDaFLjcEX0";
  cluster = [ k0 k1 k2 k3 k4 ];

  tv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKNiXlHRZyKrVEfnMHnCTboWctumTRih80NHOVFog8bn";
  office = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNhknXC4pUYgz1eU1FNgpuy/zPIxaH9Rh5MP4+7Qku0";
  bedroom = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFjdkSO9y85QQ0n6bmXI2RJLVYBsEVMPLtRoFCVHk39";
in
{
  "k3s.age".publicKeys = [ hall ] ++ cluster;
  "spotify.age".publicKeys = [ hall office ];
}
