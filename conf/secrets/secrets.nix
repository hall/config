let
  hall = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAPZfm37xYNbJ90AHSe2+SeWhCpQ1sz1wFLEb9805ZW"; # github

  k0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVGaaL/HIr/0HdaqSoZ4giMzqBEpZ/eWBwD6ct0lB2K";
  k1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQIAo8GyvynexxqaeUlkQPjqnU9Ky5gRr6Ut83XJhpy";
  k2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBT90Iw3wAsrb7asEcxY3RamKZxTIr1Gs2ZyBsxgg7z";

  office = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNhknXC4pUYgz1eU1FNgpuy/zPIxaH9Rh5MP4+7Qku0";

in
{
  "k3s.age".publicKeys = [ hall k0 k1 ];
  "spotify.age".publicKeys = [ hall office ];
}
