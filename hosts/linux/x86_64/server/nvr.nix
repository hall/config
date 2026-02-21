{ flake, pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };
  networking.firewall = {
    allowedTCPPorts = [
      # 5000
      8554 # rtsp
      8555 # webrtc
    ];
    allowedUDPPorts = [
      8554 # rtsp
      8555 # webrtc
    ];
  };

  services = {
    go2rtc = {
      enable = true;
      settings = {
        streams = {
          "front-yard" = [
            "ffmpeg:rtsp://admin:4mXqMGArq7ZTg52Lhzs4rRmQmQsaqc@front-yard.lan:554/cam/realmonitor?channel=1&subtype=0"
          ];
        };
        rtsp.listen = ":8554";
        webrtc.listen = ":8555";
      };
    };
    frigate = {
      enable = true;
      hostname = "nvr.${flake.lib.hostname}";
      vaapiDriver = "iHD";
      settings = {
        mqtt = {
          enabled = true;
          host = "homeassistant.lan";
          user = "frigate";
          password = "ppPKjVvFZRwuwJnqoV6B6zU9W8zqA8";
        };
        tls.enabled = false;
        auth.enabled = false;
        detectors.coral = {
          enabled = true;
          type = "edgetpu";
          device = "usb";
        };
        detect = {
          enabled = true;
        };
        face_recognition = {
          enabled = true;
          model_size = "large";
        };
        ffmpeg.hwaccel_args = "preset-vaapi";
        record = {
          enabled = true;
          retain = {
            days = 7;
            mode = "all";
          };
          alerts.retain.days = 30;
          detections.retain.days = 30;
        };
        snapshots = {
          enabled = true;
        };
        # go2rtc.streams.front-yard = [
        #   "rtsp://admin:4mXqMGArq7ZTg52Lhzs4rRmQmQsaqc@front-yard.lan:554/cam/realmonitor?channel=1&subtype=2"
        # ];
        cameras = {
          front-yard = {
            enabled = true;
            zones = {
              driveway.coordinates = "0.94,1,0.676,0.58,0.707,0.251,0.559,0.216,0.305,0.535,0.093,0.642,0.003,0.727,0,1";
            };
            review = {
              alerts.required_zones = [ "driveway" ];
              detections.required_zones = [ "driveway" ];
            };
            ffmpeg = {
              # output_args.record = "preset-record-generic-audio-copy";
              inputs = [
                {
                  path = "rtsp://127.0.0.1:8554/front-yard";
                  roles = [ "detect" "record" "audio" ];
                  input_args = "preset-rtsp-restream";
                }
                # {
                #   path = "rtsp://127.0.0.1:8554/front-yard";
                #   roles = [ "detect" ];
                # }
              ];
            };
          };
        };
      };
    };
    nginx.virtualHosts."nvr.${flake.lib.hostname}" = {
      useACMEHost = flake.lib.hostname;
      acmeRoot = null;
      forceSSL = true;
    };
  };
  systemd.services.frigate = {
    # for DNS resolution of camera hostnames
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    # environment.LIBVA_DRIVER_NAME = "iHD";
    environment.PLUS_API_KEY = "469fb398-6d18-4c10-a544-ee1b2bd6e99f:b232a099af8f346f25ea01b11243b5539956b6af";
    # serviceConfig = {
    # SupplementaryGroups = [ "render" "video" ]; # for access to dev/dri/*
    # AmbientCapabilities = "CAP_PERFMON";
    # };
  };
}

