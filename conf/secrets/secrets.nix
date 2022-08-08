let
  hall = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAPZfm37xYNbJ90AHSe2+SeWhCpQ1sz1wFLEb9805ZW"; # github

  k0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVGaaL/HIr/0HdaqSoZ4giMzqBEpZ/eWBwD6ct0lB2K";
  k1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQIAo8GyvynexxqaeUlkQPjqnU9Ky5gRr6Ut83XJhpy";
  k2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBT90Iw3wAsrb7asEcxY3RamKZxTIr1Gs2ZyBsxgg7z";
  k3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqea9Z97QRtRfJbKTFhrTEmOuFmvh0TigPwl48I6U6f";
  k4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhhWN77n1+6yYJgEYEgd05wql4zJAkXbRAhz7W5I00u";
  cluster = [ k0 k1 k2 k3 k4 ];

  office = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNhknXC4pUYgz1eU1FNgpuy/zPIxaH9Rh5MP4+7Qku0";

in
{
  "k3s.age".publicKeys = [ hall ] ++ cluster;
  "spotify.age".publicKeys = [ hall office ];
}
