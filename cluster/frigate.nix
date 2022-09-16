{ kubenix, flake, vars, pkgs, ... }:
let
  roles = [
    "detect"
    "record"
    "rtmp"
  ];
in
{
  helm.releases.frigate = {
    chart = vars.template { inherit kubenix; };
    namespace = "default";
    values = {
      image = {
        repository = "blakeblackshear/frigate";
        tag = "0.11.0-rc2";
      };
      # required to access coral USB
      securityContext.privileged = true;
      # env.FRIGATE_RTSP_PASSWORD = "";
      service.main.ports.http.port = 5000;
      ingress.main = {
        enabled = true;
        hosts = [{
          host = "frigate.${flake.hostname}";
          paths = [{ path = "/"; }];
        }];
      };
      persistence = {
        data = {
          enabled = true;
          size = "1Gi";
          accessMode = "ReadWriteOnce";
          storageClass = "longhorn-static";
        };
        media = {
          enabled = true;
          size = "10Gi";
          accessMode = "ReadWriteOnce";
          storageClass = "longhorn-static";
        };
        config = {
          enabled = true;
          type = "configMap";
          # subPath = "config";
          name = "frigate-config";
          readOnly = true;
        };
        usb = {
          enabled = true;
          type = "hostPath";
          hostPath = "/dev/bus/usb";
        };
      };
      nodeSelector = {
        "${flake.hostname}/tpu" = "true";
      };

      configmap.config = {
        enabled = true;
        data."config.yml" = builtins.readFile ((pkgs.formats.yaml { }).generate "." {
          mqtt.host = "mosquitto.system";
          detectors.coral = {
            type = "edgetpu";
            device = "usb";
          };
          ffmpeg = {
            hwaccel_args = [
              "-c:v"
              "h264_v4l2m2m"
            ];

            # remove -an for audio support
            output_args.record = "-f segment -segment_time 60 -segment_format mp4 -reset_timestamps 1 -strftime 1 -c copy";
          };
          detect = {
            width = 704;
            height = 480;
          };
          record = {
            enabled = true;
            # retain.days = 0;
            events.retain.default = 10;
          };
          snapshots.enabled = true;
          cameras = {
            front_yard.ffmpeg.inputs = [{
              path = ''rtsp://admin:${vars.secret "/rtsp/front"}@front_yard:554/cam/realmonitor?channel=1&subtype=1'';
              inherit roles;
            }];
            back_yard.ffmpeg.inputs = [{
              path = ''rtsp://admin:${vars.secret "/rtsp/back"}@back_yard:554/cam/realmonitor?channel=1&subtype=1'';
              inherit roles;
            }];
            doorbell = {
              detect = {
                width = 800;
                height = 480;
              };
              motion.mask = [
                "144,304,162,302,162,275,142,275" # rental mailbox
                "47,293,58,292,60,279,50,277" # neighbor's mailbox
              ];
              ffmpeg = {
                # add pcm_s16be codec
                output_args.record = "-f segment -segment_time 60 -segment_format mp4 -reset_timestamps 1 -strftime 1 -c copy -acodec pcm_s16be";
                inputs = [
                  {
                    path = ''rtsp://admin:${vars.secret "/rtsp/doorbell"}@192.168.1.20:554/cam/realmonitor?channel=1&subtype=1'';
                    # 5fps, low res
                    inherit roles;
                    # roles = [ "detect" "rtmp" ];
                  }
                  # {
                  #   path = "rtsp://admin:${rtsp.doorbell}@192.168.1.20:554/cam/realmonitor?channel=1&subtype=1";
                  #   # 15fps, high res
                  #   roles = [ "record" ];
                  # }
                ];
              };
            };
          };
        });
      };
    };
  };
}
