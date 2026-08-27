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

    patches = [
      (pkgs.writeText "device-types.patch" ''
        diff --git a/src/config/defaults.rs b/src/config/defaults.rs
        index 72dd3e8..7a00d4f 100644
        --- a/src/config/defaults.rs
        +++ b/src/config/defaults.rs
        @@ -63,3 +63,11 @@ pub fn default_device_phone_text() -> String {
         pub fn default_device_tablet_text() -> String {
             "Tablet ".into()
         }
        +
        +pub fn default_device_desktop_text() -> String {
        +    "Desktop ".to_string()
        +}
        +
        +pub fn default_device_laptop_text() -> String {
        +    "Laptop ".to_string()
        +}
        diff --git a/src/config/mod.rs b/src/config/mod.rs
        index 8a0d981..d21f0f6 100644
        --- a/src/config/mod.rs
        +++ b/src/config/mod.rs
        @@ -113,6 +113,12 @@ pub struct Config {
             /// e.g. `"Tablet "`
             pub device_tablet_text: String,

        +    #[serde(default = "default_device_desktop_text")]
        +    pub device_desktop_text: String,
        +
        +    #[serde(default = "default_device_laptop_text")]
        +    pub device_laptop_text: String,
        +
             #[serde(default)]
             #[schemars(with = "Option<String>")]
             /// Groups notifications per app, and for each app replaces {[`Notification::Grouped`]} with the given [`NotificationFormat`]
        diff --git a/src/formatter/field.rs b/src/formatter/field.rs
        index ce338b7..a502d75 100644
        --- a/src/formatter/field.rs
        +++ b/src/formatter/field.rs
        @@ -211,6 +211,8 @@ impl FieldCategory {
                             DeviceInfo::DeviceTypeText => match info.type_ {
                                 DeviceType::Phone => Cow::Borrowed(&config.device_phone_text),
                                 DeviceType::Tablet => Cow::Borrowed(&config.device_tablet_text),
        +                        DeviceType::Desktop => Cow::Borrowed(&config.device_desktop_text),
        +                        DeviceType::Laptop => Cow::Borrowed(&config.device_laptop_text),
                             },
                         }
                     }
        diff --git a/src/wrapper/device.rs b/src/wrapper/device.rs
        index 948e1e6..69a0104 100644
        --- a/src/wrapper/device.rs
        +++ b/src/wrapper/device.rs
        @@ -100,5 +100,7 @@ dbus_enum! {
             pub enum DeviceType {
                 Phone,
                 Tablet,
        +        Desktop,
        +        Laptop,
             }
         }
      '')
    ];

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
          device_id = "d5c3a6ab621f4db0bef198bc9e5c17f1";
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
