{ pkgs, ... }: {
  laptop.enable = true;
  home = {
    enable = true;
    file = {
      ".config/autostart/kodi.desktop".source = pkgs.kodi-wayland + "/share/applications/kodi.desktop";
      # ".config/autostart/steam.desktop".source = pkgs.steam + "/share/applications/steam.desktop";
      # TODO: this file keeps reverting
      # https://github.com/xbmc/xbmc/blob/d212b0a65700fdfa958f87c9617be3117bd89f16/xbmc/peripherals/devices/PeripheralCecAdapter.cpp#L48
      ".kodi/userdata/peripheral_data/usb_2548_1002_CEC_Adapter.xml".text = ''
          <settings>
            <setting id="activate_source" value="1"/>
            <setting id="button_release_delay_ms" value="0"/>
            <setting id="button_repeat_rate_ms" value="0"/>
            <setting id="cec_hdmi_port" value="1"/>
            <setting id="cec_standby_screensaver" value="0"/>
            <setting id="cec_wake_screensaver" value="0"/>
            <setting id="connected_device" value="36038"/>
            <setting id="device_name" value="Kodi"/>
            <setting id="device_type" value="36052"/>
            <setting id="double_tap_timeout_ms" value="300"/>
            <setting id="enabled" value="1"/>
            <setting id="pause_or_stop_playback_on_deactivate" value="36045"/>
            <setting id="pause_playback_on_deactivate" value="0"/>
            <setting id="physical_address" value="0"/>
            <setting id="power_avr_on_as" value="1"/>
            <setting id="send_inactive_source" value="0"/>
            <setting id="standby_devices" value="36037"/>
            <setting id="standby_devices_advanced" value=""/>
            <setting id="standby_pc_on_tv_standby" value="36028"/>
            <setting id="standby_tv_on_pc_standby" value="0"/>
            <setting id="tv_vendor" value="0"/>
            <setting id="use_tv_menu_language" value="1"/>
            <setting id="wake_devices" value="36037"/>
            <setting id="wake_devices_advanced" value=""/>
        </settings>
      '';
    };
  };
}
