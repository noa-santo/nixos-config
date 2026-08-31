# tags: kde-connect
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.kdeconnect_waybar.homeManagerModules.default
  ];

  home.packages = [
    pkgs.kdePackages.kdeconnect-kde
  ];

  programs.kdeconnect-waybar = {
    enable = true;
    settings = {
      device_id = "d5c3a6ab621f4db0bef198bc9e5c17f1";
      update_interval_secs = 5.0;
      format = "{Battery::ChargePercent}% {Battery::ChargeTexts} {Notification::Grouped}";
      tooltip_format = "Device type: {DeviceInfo::DeviceTypeText}\nBattery status: {Battery::IsChargingText} {Battery::ChargePercent}% \nNotifications:\n{Notification::Single}";
      device_not_found_text = "";
      device_not_found_tooltip_text = "Device not found make sure kdeconnect is running and phone is connected";
      device_phone_text = "Phone ";
      device_tablet_text = "Tablet ";
      device_laptop_text = "Laptop ";
      device_desktop_text = "Desktop ";
      is_charging_text = "󰂄 Charging...";
      isnt_charging_text = "󱟩 Not charging";
      notification_grouped_format = "{CustomIcon} {CountText} ";
      notification_single_format = "  -{CustomIcon} : {Title}\n{Content}\n";
      app_icons = {
        "Instagram" = "";
        "Snapchat" = "";
        "YouTube" = "󰗃";
        "WhatsApp" = "";
        "Discord" = "";
        "Signal" = "󰭹";
        "Gmail" = "";
        "YouTube Morphe" = "󰗃";
        "YouTUbe" = "󰗃";
      };
      notifications_count_text = {
        "1" = "󰲠";
        "2" = "󰲢";
        "3" = "󰲤";
        "4" = "󰲦";
        "5" = "󰲨";
        "6" = "󰲪";
        "7" = "󰲬";
        "8" = "󰲮";
        "9" = "󰲰";
        "0" = "󰲲";
      };
      is_charging_texts = [
        "󰢜"
        "󰂆"
        "󰂇"
        "󰂈"
        "󰢝"
        "󰂉"
        "󰢞"
        "󰂊"
        "󰂋"
        "󰂅"
      ];
      isnt_charging_texts = [
        "󰁺"
        "󰁻"
        "󰁼"
        "󰁽"
        "󰁾"
        "󰁿"
        "󰂀"
        "󰂁"
        "󰂂"
        "󰁹"
      ];
      charge_ranges = [
        10
        20
        30
        40
        50
        60
        70
        80
        90
      ];
    };
  };
}
