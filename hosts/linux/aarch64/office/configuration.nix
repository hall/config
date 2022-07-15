{ flake, pkgs, ... }:
{
  services = {
    snapserver = {
      enable = true;
      openFirewall = true;
      streams = {
        all = {
          type = "meta";
          location = "/turntable/spotify";
        };
        turntable = {
          type = "tcp";
          location = "0.0.0.0:49566";
          query = {
            sampleformat = "44100:16:2";
          };
        };
        spotify = {
          type = "librespot";
          location = "${pkgs.librespot}/bin/librespot";
          query = {
            name = "spotify";
            username = flake.email;
            password = flake.lib.pass "spotify/${flake.username}";
            devicename = "home";
            volume = "60";
          };
        };
      };
    };
  };

  systemd.services = {
    # snapcast-sink = {
    #   wantedBy = [ "pipewire.service" ];
    #   after = [ "pipewire.service" ];
    #   bindsTo = [ "pipewire.service" ];
    #   path = with pkgs; [
    #     gawk
    #     pulseaudio
    #   ];
    #   script = ''
    #     pactl load-module module-pipe-sink file=/run/snapserver/pipewire sink_name=Snapcast format=s16le rate=48000
    #   '';
    # };

    snapclient = {
      wantedBy = [
        "pipewire.service"
        "multi-user.target" # enable on boot
      ];
      after = [
        "pipewire.service"
      ];
      serviceConfig = {
        ExecStart = "${pkgs.snapcast}/bin/snapclient -h ::1";
      };
    };
  };

}
