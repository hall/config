# Raspberry Pi 4 Access Point
{ pkgs, ... }: {
  imports = [
    ./networking.nix
  ];

  boot.kernelModules = [
    "brcmfmac" # Built-in WiFi
    "bridge"
  ];

  environment.systemPackages = with pkgs; [
    iw
    wirelesstools
  ];

  # Placeholder - generate with: ssh-keyscan -qt ed25519 ap1
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH6DSDGDvYlysCDsQ6mSBTXclxtd2aCE+LlM6Y+CxOdr";
}
