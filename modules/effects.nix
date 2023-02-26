{ lib, config, pkgs, flake, ... }:
with lib;
let
  name = "effects";
  cfg = config.services.${name};
in
{
  options.services.${name} = {
    enable = mkEnableOption "effects service";
    kernel = mkOption {
      type = types.str;
      description = "the udev kernel targetting the USB device; hopefully can be replaced with something better";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.${name} = {
      enable = true;
      environment = {
        XDG_RUNTIME_DIR = "/run/user/1000";
        DISPLAY = ":0.0";
      };
      serviceConfig = {
        Type = "forking";
      };
      script = ''
        #!${pkgs.bash}/bin/bash
        if ! pgrep ${name}; then
          ${flake.packages.${name}}/bin/${name} &
        fi

        dev=usb-Generic_USB_HP_MIC_Adapter-00
        in=alsa_input.$dev.iec958-stereo.2
        out=alsa_output.$dev.iec958-stereo.3

        sleep 1  # wait for app to register with pw

        # disconnect any links which auto-connected
        ${pkgs.pipewire}/bin/pw-link -Il \
          | ${pkgs.gnugrep}/bin/grep effects \
          | ${pkgs.gawk}/bin/awk '{print $1}' \
          | xargs -I {} ${pkgs.bash}/bin/sh -c '${pkgs.pipewire}/bin/pw-link -d {} || true'

        ${pkgs.pipewire}/bin/pw-link $in:capture_MONO ${name}:in_0
        ${pkgs.pipewire}/bin/pw-link ${name}:out_0 $out:playback_FL
        ${pkgs.pipewire}/bin/pw-link ${name}:out_0 $out:playback_FR
      '';
    };
    services.udev.extraRules = ''
      # udevadm monitor --environment
      # sudo udevadm info -q all -a $DEVLINKS[0]
      ACTION=="add",\
        KERNEL=="${cfg.kernel}",\
        SUBSYSTEM=="sound",\
        ATTRS{interface}=="iRig HD 2",\
        TAG+="systemd"\
        ENV{SYSTEMD_USER_WANTS}="${name}"
    '';
  };
}
