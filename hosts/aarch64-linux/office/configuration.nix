{ config, lib, pkgs, ... }:
# let
#   username = "bryton";
# in
{
  # numeric password is currently required to unlock a session
  # TODO change me!
  # users.users.${username}.hashedPassword = "$6$zActsdzv754qmpNR$TVgNLHx4/0Q3GIqirequckS252LvYFomx11IimP8uuk.soV8CQFIUDcjhhF7lHz5BurJZJLj/QlGOHZTYAX8R1";
  # users.users.root.hashedPassword = "$6$Jv0Cl55I5TN$BAwcCxOv7Yvy3z369jwFU7/x.TfUOCEvM6FVxsQOPWJEFgKYhZvsgDmvF3gb8dgOAntHvYHR8QF0obpezLx3v1";

  networking = {
    # FIXME : configure usb rndis through networkmanager in the future.
    # Currently this relies on stage-1 having configured it.
    # networkmanager.unmanaged = [ "rndis0" "usb0" ];
    hostname = "office";
  };

  # services.openssh = {
  #   enable = true;
  #   passwordAuthentication = false;
  #   permitRootLogin = "no";
  #   allowSFTP = false;
  # };
}