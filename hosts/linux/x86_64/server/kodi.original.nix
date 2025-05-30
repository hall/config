{ pkgs, flake, ... }:
let
  kodi = pkgs.kodi.withPackages (p: with p; [
    # artic: zephyr - reloaded
    netflix
    # disney+
    # hulu
    # crunchyroll
    jellyfin
    # joystick
    # youtube
    steam-library
    # steam-launcher # doesn't work?
    libretro
  ]);
in
{

  users.extraUsers.kodi.isNormalUser = true;
  services.cage = {
    enable = true;
    user = "kodi";
    program = "${kodi}/bin/kodi-standalone";
  };

  environment.systemPackages = [ kodi ];
  hardware.bluetooth.enable = true;

  # systemd.services.kodi = {
  #   enable = false;
  #   description = "Kodi media center";
  #   wantedBy = [ "multi-user.target" ];
  #   wants = [
  #     "network-online.target"
  #     "dbus.socket"
  #   ];
  #   after = [
  #     "network-online.target"
  #     "sound.target"
  #     "systemd-user-sessions.service"
  #   ];
  #   environment = {
  #     HOME = "%S/kodi";
  #     LIBVA_DRIVER_NAME = "iHD";
  #     KODI_DATA = "%S/kodi"; # $STATE_DIRECTORY
  #   };
  #   serviceConfig = {
  #     Type = "simple";
  #     Restart = "always";
  #     DynamicUser = true;
  #     SupplementaryGroups = "audio dialout input video";
  #     AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
  #     StateDirectory = "kodi";
  #     RuntimeDirectory = "kodi";
  #     # tODO: fails to start so manually created for now
  #     # ExecStartPre = "ln -fs /dev/null $STATE_DIRECTORY/temp/kodi.log";
  #     ExecStart = "${kodi}/bin/kodi-standalone --logging=console --audio-backend=alsa";
  #     # ExecStop = "${pkgs.procps}/bin/pkill kodi";
  #     TimeoutStopSec = "15s";
  #     TimeoutStopFailureMode = "kill";
  #   };
  # };

  services = {
    upower.enable = true;
    # lirc.enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [
      8080 # web server
    ];
    allowedUDPPorts = [
      9777 # event server
    ];
  };

  # home-manager.users.${flake.lib.username} = {
  #   programs.kodi = {
  #     # enable = true;
  #     package = kodi;
  #     datadir = "/var/lib/kodi";
  #     addonSettings = {
  #       "skin.artic.zephyr.mod" = {
  #         "focuscolor.name" = "22000000";
  #       };
  #     };
  #     # settings = {};
  #   };
  #   home.file = {
  #     # TODO: this file keeps reverting
  #     # https://github.com/xbmc/xbmc/blob/d212b0a65700fdfa958f87c9617be3117bd89f16/xbmc/peripherals/devices/PeripheralCecAdapter.cpp#L48
  #     ".kodi/userdata/peripheral_data/usb_2548_1002_CEC_Adapter.xml".text = ''
  #         <settings>
  #           <setting id="activate_source" value="1"/>
  #           <setting id="button_release_delay_ms" value="0"/>
  #           <setting id="button_repeat_rate_ms" value="0"/>
  #           <setting id="cec_hdmi_port" value="1"/>
  #           <setting id="cec_standby_screensaver" value="0"/>
  #           <setting id="cec_wake_screensaver" value="0"/>
  #           <setting id="connected_device" value="36038"/>
  #           <setting id="device_name" value="Kodi"/>
  #           <setting id="device_type" value="36052"/>
  #           <setting id="double_tap_timeout_ms" value="300"/>
  #           <setting id="enabled" value="1"/>
  #           <setting id="pause_or_stop_playback_on_deactivate" value="36045"/>
  #           <setting id="pause_playback_on_deactivate" value="0"/>
  #           <setting id="physical_address" value="0"/>
  #           <setting id="power_avr_on_as" value="1"/>
  #           <setting id="send_inactive_source" value="0"/>
  #           <setting id="standby_devices" value="36037"/>
  #           <setting id="standby_devices_advanced" value=""/>
  #           <setting id="standby_pc_on_tv_standby" value="36028"/>
  #           <setting id="standby_tv_on_pc_standby" value="0"/>
  #           <setting id="tv_vendor" value="0"/>
  #           <setting id="use_tv_menu_language" value="1"/>
  #           <setting id="wake_devices" value="36037"/>
  #           <setting id="wake_devices_advanced" value=""/>
  #       </settings>
  #     '';
  #   };
  # };

  # systemd.services.cec-toggle.serviceConfig = {
  #   Type = "oneshot";
  #   ExecStart = pkgs.writeShellScript "cec-toggle" ''
  #     if ${pkgs.procps}/bin/pgrep kodi &> /dev/null 2>&1; then
  #       ${pkgs.curl}/bin/curl --silent -X POST -H 'Content-Type: application/json' http://localhost:8080/jsonrpc -d '${builtins.toJSON {
  #         id = 1;
  #         jsonrpc = "2.0";
  #         method = "Addons.ExecuteAddon";
  #         params = {
  #           addonid = "script.json-cec";
  #           params.command = "toggle";
  #         };
  #       }}'
  #     else
  #       if echo pow 0 | ${pkgs.libcec}/bin/cec-client -s -d 1 | ${pkgs.gnugrep}/bin/grep -q "status: on"; then
  #         COMMAND=standby
  #       fi
  #       echo ''${COMMAND:-on} 0 | ${pkgs.libcec}/bin/cec-client -s -d 1
  #     fi
  #   '';
  # };

}

