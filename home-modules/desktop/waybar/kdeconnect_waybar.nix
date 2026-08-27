# tags: kde-connect
{
  pkgs,
  inputs,
  lib,
  ...
}:

let
  toolchain = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}.latest.toolchain;
  rustPlatform = pkgs.makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  };
  kdeconnect-waybar = rustPlatform.buildRustPackage {
    pname = "kdeconnect_waybar";
    version = "1.1.1";
    src = pkgs.fetchFromGitHub {
      owner = "Adrien5902";
      repo = "kdeconnect_waybar";
      rev = "0b58775be0feeda14ee5a04e415327730d0777c3";
      hash = "sha256-1pcKR/a6mmrS9/AykBiTOP3McQjwbJ8Wx1lV82jLND0=";
    };
    cargoHash = "sha256-DpY++t4YaU/oCjSwyiPwyXA0U6S/R16mTRF/8ctQ8MM=";
    doCheck = false;
    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.makeWrapper
    ];
    buildInputs = [
      pkgs.glib
      pkgs.dbus
    ];

    postInstall = ''
      wrapProgram $out/bin/kdeconnect_waybar \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.dbus ]}
    '';
  };
in
{
  home.packages = [
    pkgs.kdePackages.kdeconnect-kde
    kdeconnect-waybar
  ];

  home.file.".config/kdeconnect_waybar/config.json" = {
    text = builtins.toJSON {
      "$schema" = "./config.schema.json";
      configs = [
        {
          update_interval_secs = 5;
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
        }
      ];
    };
  };
}
