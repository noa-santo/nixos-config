{config, pkgs, ...}:
let
  hanabiExtension = (import ./hanabi.nix { inherit pkgs; }).hanabi;
in
{
  home.pointerCursor = {
      name = "Bibata-Modern-Pink";
      package = (pkgs.stdenvNoCC.mkDerivation {
        pname = "bibata-modern-pink";
        version = "1.0";
        src = ../../themes/icons;

        installPhase = ''
          mkdir -p $out/share/icons
          cp -r Bibata-Modern-Pink $out/share/icons/
        '';
      });
      size = 24;
      x11 = {
        enable = true;
        defaultCursor = "Bibata-Modern-Pink";
      };
      sway.enable = true;
    };

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.blur-my-shell; }
      { package = pkgs.gnomeExtensions.gsconnect; }
      { package = pkgs.gnomeExtensions.runcat; }
      # { package = pkgs.gnomeExtensions.drive-menu; } # TODO: find correct name to install package
      { package = pkgs.gnomeExtensions.yakuake; }
      { package = pkgs.gnomeExtensions.arcmenu; }
      { package = pkgs.gnomeExtensions.customize-clock-on-lock-screen; }
      { package = pkgs.gnomeExtensions.just-perfection; }
      { package = pkgs.gnomeExtensions.quick-lofi; }
      { package = pkgs.gnomeExtensions.reboottouefi; }
      { package = pkgs.gnomeExtensions.vitals; }
      { package = pkgs.gnomeExtensions.clipboard-indicator; }
      { package = pkgs.gnomeExtensions.paperwm; }
      { package = pkgs.gnomeExtensions.keep-awake; }
      { package = pkgs.gnomeExtensions.color-picker; }
      { package = pkgs.gnomeExtensions.appindicator; }
      { package = pkgs.gnomeExtensions.rounded-corners; }
      { package = pkgs.gnomeExtensions.messaging-menu; }
      { package = pkgs.gnomeExtensions.top-bar-organizer; }
      { id = "hanabi-extension@jeffshee.github.io"; package = hanabiExtension; }
    ];
  };


  dconf.settings = {
    "org/fedorahosted/background-logo-extension" = {
      logo-always-visible = true;
      logo-border = "uint32 46";
      logo-file = "/etc/skel/.config/neofetch/logo.png";
      logo-file-dark = "/etc/skel/.config/neofetch/logo.png";
      logo-opacity = "uint32 137";
      logo-position = "bottom-right";
      logo-size = "10.485232067510548";
    };
    "org/fedoraproject/FirewallConfig" = {
      show-active-bindings = true;
      show-ipsets = true;
    };
    "org/gnome/Console" = {
      theme = "night";
    };
    "org/gnome/Geary" = {
      compose-as-html = true;
      formatting-toolbar-visible = false;
      images-trusted-domains = [ "maps.com" ];
      migrated-config = true;
      window-height = 1036;
      window-maximize = false;
      window-width = 1717;
    };
    "org/gnome/Lollypop" = {
      flatpak-access-migration = true;
      notification-flag = 2;
      volume-rate = "0.5376129150390625";
      window-maximized = false;
      window-position = [  ];
      window-size = [  ];
    };
    "org/gnome/TextEditor" = {
      style-variant = "dark";
    };
    "org/gnome/Totem" = {
      active-plugins = [ "skipto" "recent" "movie-properties" "apple-trailers" "autoload-subtitles" "mpris" "vimeo" "screensaver" "screenshot" "save-file" "open-directory" "rotation" "variable-rate" ];
      subtitle-encoding = "UTF-8";
    };
    "org/gnome/Weather" = {
      locations = [ "Halifax" "CYHZ" "Munich" "EDDM" ];
      window-height = 415;
      window-maximized = false;
      window-width = 440;
    };
    "org/gnome/baobab/ui" = {
      is-maximized = false;
      window-size = "(960, 600)";
    };
    "org/gnome/calculator" = {
      accuracy = 9;
      angle-units = "degrees";
      base = 10;
      button-mode = "advanced";
      number-format = "automatic";
      show-thousands = false;
      show-zeroes = false;
      source-currency = "";
      source-units = "meters-second";
      target-currency = "";
      target-units = "kilometers-hour";
      window-maximized = false;
      window-size = "(1906, 1036)";
      word-size = 64;
    };
    "org/gnome/calendar" = {
      active-view = "week";
      week-view-zoom-level = "1.0";
      window-maximized = false;
      window-size = "(768, 1036)";
    };
    "org/gnome/clocks" = {
      timers = [ "duration" "name" "pizza" ];
      world-clocks = [ "location" "Halifax" "CYHZ" ];
    };
    "org/gnome/clocks/state/window" = {
      maximized = false;
      panel-id = "timer";
      size = "(870, 690)";
    };
    "org/gnome/control-center" = {
      last-panel = "search";
      window-state = "(980, 640, false)";
    };
    "org/gnome/desktop/a11y" = {
      always-show-universal-access-status = false;
    };
    "org/gnome/desktop/a11y/applications" = {
      screen-keyboard-enabled = false;
      screen-magnifier-enabled = false;
    };
    "org/gnome/desktop/a11y/interface" = {
      high-contrast = false;
    };
    "org/gnome/desktop/app-folders" = {
      folder-children = [ "System" "Utilities" "YaST" "Pardus" ];
    };
    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = [ "X-Pardus-Apps" ];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };
    "org/gnome/desktop/app-folders/folders/System" = {
      apps = [ "org.gnome.baobab.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Logs.desktop" "org.gnome.SystemMonitor.desktop" ];
      name = "X-GNOME-Shell-System.directory";
      translate = true;
    };
    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "org.gnome.Connections.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.font-viewer.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" ];
      name = "X-GNOME-Shell-Utilities.directory";
      translate = true;
    };
    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/break-reminders/eyesight" = {
      play-sound = true;
    };
    "org/gnome/desktop/break-reminders/movement" = {
      duration-seconds = "uint32 300";
      interval-seconds = "uint32 1800";
      play-sound = true;
    };
    "org/gnome/desktop/input-sources" = {
      mru-sources = [ "xkb" "de+qwerty" ];
      per-window = false;
      show-all-sources = true;
      sources = [ "xkb" "de+qwerty" "xkb" "us" ];
      xkb-options = [ "lv3:ralt_switch" ];
    };
    "org/gnome/desktop/interface" = {
      accent-color = "purple";
      color-scheme = "prefer-dark";
      cursor-theme = "Bibata-Modern-Pink";
      enable-animations = true;
      enable-hot-corners = false;
      font-antialiasing = "rgba";
      font-hinting = "full";
      show-battery-percentage = true;
      toolkit-accessibility = false;
    };
    "org/gnome/desktop/notifications" = {
      application-children = [ "org-gnome-software" "firefox" "org-gnome-console" "org-gnome-characters" "ulauncher" "dev-vencord-vesktop" "com-spotify-client" "com-brave-browser" "gnome-power-panel" "org-gnome-nautilus" "org-gnome-builder" "org-gnome-shell-extensions-gsconnect" "io-github-qwersyk-newelle" "org-gnome-evolution-alarm-notify" "com-usebottles-bottles" "com-obsproject-studio" "de-haeckerfelix-fragments" "org-gnome-firmware" "org-gnome-extensions" "org-gnome-tweaks" "org-gnome-boxes" "org-gnome-geary" "com-discordapp-discord" "waydroid" "waydroid-com-android-vending" "waydroid-org-fdroid-fdroid" "waydroid-com-roblox-client" "jetbrains-toolbox" "jetbrains-webstorm-85ec44be-6d8d-42a4-a6e8-29c209125efb" "com-termius-termius" "com-modrinth-modrinthapp" "waydroid-com-android-settings" "waydroid-org-lineageos-jelly" "appimagelaunchersettings" "appimagekit-d8f769bc9f9c41674793686e08ccce5c-obsidian" "jetbrains-goland-de06ab32-1063-42af-9586-deda6ab15947" "sh-ppy-osu" "org-gnome-clocks" "vesktop" "io-github-thaunknown-miru" "jetbrains-pycharm-efc1bfaf-ec1b-4217-86b5-defbcdfb9918" "kitty" "com-dec05eba-gpu-screen-recorder" "audacity" "jetbrains-fleet" "org-gnome-settings" "jetbrains-clion-d1058284-5b80-4e43-9d1f-627829ece02b" "org-gnome-fractal" "filezilla" "com-mattjakeman-extensionmanager" "org-gnome-gitlab-somas-apostrophe" "org-gimp-gimp" "org-gnome-systemmonitor" "org-gnome-shell-extensions" "org-gnome-shell-extensions-gsconnect-preferences" "jetbrains-fleet-db1ed3eb-c0b7-4214-a168-b944380e019c" "org-gnome-texteditor" "org-gnome-lollypop" "org-gnome-terminal" "app-zen-browser-zen" "org-gnome-evince" "org-gnome-ghex" "re-rizin-cutter" "org-ghidra-sre-ghidra" "org-wireshark-wireshark" "com-github-draqzziq-riscvsimulator" "org-bluej-bluej" "xdg-desktop-portal-gnome" "moe-nyarchlinux-updater" "org-manjaro-pamac-manager" "moe-nyarchlinux-assistant" "jetbrains-studio-d9bfc116-8a6b-41d9-87d0-4d14f1833f0a" "org-rncbc-qjackctl" "org-rncbc-qsynth" "com-adrienplazas-metronome" ];
      show-banners = true;
    };
    "org/gnome/desktop/notifications/application/app-zen-browser-zen" = {
      application-id = "app.zen_browser.zen.desktop";
    };
    "org/gnome/desktop/notifications/application/appimagekit-d8f769bc9f9c41674793686e08ccce5c-obsidian" = {
      application-id = "appimagekit_d8f769bc9f9c41674793686e08ccce5c-Obsidian.desktop";
    };
    "org/gnome/desktop/notifications/application/appimagelaunchersettings" = {
      application-id = "appimagelaunchersettings.desktop";
    };
    "org/gnome/desktop/notifications/application/audacity" = {
      application-id = "audacity.desktop";
    };
    "org/gnome/desktop/notifications/application/com-adrienplazas-metronome" = {
      application-id = "com.adrienplazas.Metronome.desktop";
    };
    "org/gnome/desktop/notifications/application/com-brave-browser" = {
      application-id = "com.brave.Browser.desktop";
    };
    "org/gnome/desktop/notifications/application/com-dec05eba-gpu-screen-recorder" = {
      application-id = "com.dec05eba.gpu_screen_recorder.desktop";
    };
    "org/gnome/desktop/notifications/application/com-discordapp-discord" = {
      application-id = "com.discordapp.Discord.desktop";
    };
    "org/gnome/desktop/notifications/application/com-github-draqzziq-riscvsimulator" = {
      application-id = "com.github.draqzziq.riscvsimulator.desktop";
    };
    "org/gnome/desktop/notifications/application/com-mattjakeman-extensionmanager" = {
      application-id = "com.mattjakeman.ExtensionManager.desktop";
    };
    "org/gnome/desktop/notifications/application/com-modrinth-modrinthapp" = {
      application-id = "com.modrinth.ModrinthApp.desktop";
    };
    "org/gnome/desktop/notifications/application/com-obsproject-studio" = {
      application-id = "com.obsproject.Studio.desktop";
    };
    "org/gnome/desktop/notifications/application/com-spotify-client" = {
      application-id = "com.spotify.Client.desktop";
    };
    "org/gnome/desktop/notifications/application/com-termius-termius" = {
      application-id = "com.termius.Termius.desktop";
    };
    "org/gnome/desktop/notifications/application/com-usebottles-bottles" = {
      application-id = "com.usebottles.bottles.desktop";
    };
    "org/gnome/desktop/notifications/application/de-haeckerfelix-fragments" = {
      application-id = "de.haeckerfelix.Fragments.desktop";
    };
    "org/gnome/desktop/notifications/application/dev-vencord-vesktop" = {
      application-id = "dev.vencord.Vesktop.desktop";
    };
    "org/gnome/desktop/notifications/application/filezilla" = {
      application-id = "filezilla.desktop";
    };
    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };
    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };
    "org/gnome/desktop/notifications/application/io-github-qwersyk-newelle" = {
      application-id = "io.github.qwersyk.Newelle.desktop";
    };
    "org/gnome/desktop/notifications/application/io-github-thaunknown-miru" = {
      application-id = "io.github.thaunknown.miru.desktop";
    };
    "org/gnome/desktop/notifications/application/jetbrains-clion-d1058284-5b80-4e43-9d1f-627829ece02b" = {
      application-id = "jetbrains-clion-d1058284-5b80-4e43-9d1f-627829ece02b.desktop";
    };
    "org/gnome/desktop/notifications/application/jetbrains-fleet-db1ed3eb-c0b7-4214-a168-b944380e019c" = {
      application-id = "jetbrains-fleet-db1ed3eb-c0b7-4214-a168-b944380e019c.desktop";
    };
    "org/gnome/desktop/notifications/application/jetbrains-fleet" = {
      application-id = "jetbrains-fleet.desktop";
    };
    "org/gnome/desktop/notifications/application/jetbrains-goland-de06ab32-1063-42af-9586-deda6ab15947" = {
      application-id = "jetbrains-goland-de06ab32-1063-42af-9586-deda6ab15947.desktop";
    };
    "org/gnome/desktop/notifications/application/jetbrains-pycharm-efc1bfaf-ec1b-4217-86b5-defbcdfb9918" = {
      application-id = "jetbrains-pycharm-efc1bfaf-ec1b-4217-86b5-defbcdfb9918.desktop";
    };
    "org/gnome/desktop/notifications/application/jetbrains-studio-d9bfc116-8a6b-41d9-87d0-4d14f1833f0a" = {
      application-id = "jetbrains-studio-d9bfc116-8a6b-41d9-87d0-4d14f1833f0a.desktop";
    };
    "org/gnome/desktop/notifications/application/jetbrains-toolbox" = {
      application-id = "jetbrains-toolbox.desktop";
    };
    "org/gnome/desktop/notifications/application/jetbrains-webstorm-85ec44be-6d8d-42a4-a6e8-29c209125efb" = {
      application-id = "jetbrains-webstorm-85ec44be-6d8d-42a4-a6e8-29c209125efb.desktop";
    };
    "org/gnome/desktop/notifications/application/kitty" = {
      application-id = "kitty.desktop";
    };
    "org/gnome/desktop/notifications/application/moe-nyarchlinux-assistant" = {
      application-id = "moe.nyarchlinux.assistant.desktop";
    };
    "org/gnome/desktop/notifications/application/moe-nyarchlinux-updater" = {
      application-id = "moe.nyarchlinux.updater.desktop";
    };
    "org/gnome/desktop/notifications/application/org-bluej-bluej" = {
      application-id = "org.bluej.BlueJ.desktop";
    };
    "org/gnome/desktop/notifications/application/org-ghidra-sre-ghidra" = {
      application-id = "org.ghidra_sre.Ghidra.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gimp-gimp" = {
      application-id = "org.gimp.GIMP.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-boxes" = {
      application-id = "org.gnome.Boxes.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-builder" = {
      application-id = "org.gnome.Builder.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-characters" = {
      application-id = "org.gnome.Characters.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-clocks" = {
      application-id = "org.gnome.clocks.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-evince" = {
      application-id = "org.gnome.Evince.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-evolution-alarm-notify" = {
      application-id = "org.gnome.Evolution-alarm-notify.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-extensions" = {
      application-id = "org.gnome.Extensions.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-firmware" = {
      application-id = "org.gnome.Firmware.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-fractal" = {
      application-id = "org.gnome.Fractal.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-geary" = {
      application-id = "org.gnome.Geary.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-ghex" = {
      application-id = "org.gnome.GHex.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-gitlab-somas-apostrophe" = {
      application-id = "org.gnome.gitlab.somas.Apostrophe.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-lollypop" = {
      application-id = "org.gnome.Lollypop.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-shell-extensions-gsconnect-preferences" = {
      application-id = "org.gnome.Shell.Extensions.GSConnect.Preferences.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-shell-extensions-gsconnect" = {
      application-id = "org.gnome.Shell.Extensions.GSConnect.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-shell-extensions" = {
      application-id = "org.gnome.Shell.Extensions.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-software" = {
      application-id = "org.gnome.Software.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-systemmonitor" = {
      application-id = "org.gnome.SystemMonitor.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-terminal" = {
      application-id = "org.gnome.Terminal.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-texteditor" = {
      application-id = "org.gnome.TextEditor.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-tweaks" = {
      application-id = "org.gnome.tweaks.desktop";
    };
    "org/gnome/desktop/notifications/application/org-manjaro-pamac-manager" = {
      application-id = "org.manjaro.pamac.manager.desktop";
    };
    "org/gnome/desktop/notifications/application/org-rncbc-qjackctl" = {
      application-id = "org.rncbc.qjackctl.desktop";
    };
    "org/gnome/desktop/notifications/application/org-rncbc-qsynth" = {
      application-id = "org.rncbc.qsynth.desktop";
    };
    "org/gnome/desktop/notifications/application/org-wireshark-wireshark" = {
      application-id = "org.wireshark.Wireshark.desktop";
    };
    "org/gnome/desktop/notifications/application/re-rizin-cutter" = {
      application-id = "re.rizin.cutter.desktop";
    };
    "org/gnome/desktop/notifications/application/sh-ppy-osu" = {
      application-id = "sh.ppy.osu.desktop";
    };
    "org/gnome/desktop/notifications/application/ulauncher" = {
      application-id = "ulauncher.desktop";
    };
    "org/gnome/desktop/notifications/application/vesktop" = {
      application-id = "vesktop.desktop";
    };
    "org/gnome/desktop/notifications/application/waydroid-com-android-settings" = {
      application-id = "waydroid.com.android.settings.desktop";
    };
    "org/gnome/desktop/notifications/application/waydroid-com-android-vending" = {
      application-id = "waydroid.com.android.vending.desktop";
    };
    "org/gnome/desktop/notifications/application/waydroid-com-roblox-client" = {
      application-id = "waydroid.com.roblox.client.desktop";
    };
    "org/gnome/desktop/notifications/application/waydroid-org-fdroid-fdroid" = {
      application-id = "waydroid.org.fdroid.fdroid.desktop";
    };
    "org/gnome/desktop/notifications/application/waydroid-org-lineageos-jelly" = {
      application-id = "waydroid.org.lineageos.jelly.desktop";
    };
    "org/gnome/desktop/notifications/application/waydroid" = {
      application-id = "Waydroid.desktop";
    };
    "org/gnome/desktop/notifications/application/xdg-desktop-portal-gnome" = {
      application-id = "xdg-desktop-portal-gnome.desktop";
    };
    "org/gnome/desktop/privacy" = {
      old-files-age = "uint32 30";
      recent-files-max-age = -1;
      remove-old-temp-files = true;
    };
    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/search-providers" = {
      enabled = [ "org.gnome.Weather.desktop" ];
      sort-order = [ "org.gnome.Settings.desktop" "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
    };
    "org/gnome/epiphany/state" = {
      is-maximized = true;
      window-size = "(3840, 2128)4";
    };
    "org/gnome/desktop/session" = {
      idle-delay = "uint32 300";
    };
    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = false;
      event-sounds = true;
      theme-name = "__custom";
    };
    "org/gnome/desktop/wm/keybindings" = {
      activate-window-menu = "@as []";
      maximize = "@as []";
      move-to-monitor-down = "@as []";
      move-to-monitor-left = "@as []";
      move-to-monitor-right = "@as []";
      move-to-monitor-up = "@as []";
      move-to-workspace-down = "@as []";
      move-to-workspace-left = "@as []";
      move-to-workspace-right = "@as []";
      move-to-workspace-up = "@as []";
      switch-applications = "@as []";
      switch-applications-backward = "@as []";
      switch-group = "@as []";
      switch-group-backward = "@as []";
      switch-panels = "@as []";
      switch-panels-backward = "@as []";
      switch-to-workspace-1 = "@as []";
      switch-to-workspace-last = "@as []";
      switch-to-workspace-left = "@as []";
      switch-to-workspace-right = "@as []";
      switch-windows = "@as []";
      unmaximize = "@as []";
    };
    "org/gnome/desktop/wm/preferences" = {
      action-middle-click-titlebar = "none";
      button-layout = "appmenu:minimize,maximize,close";
      visual-bell = false;
      visual-bell-type = "frame-flash";
    };
    "org/gnome/evince/default" = {
      continuous = true;
      dual-page = false;
      dual-page-odd-left = false;
      enable-spellchecking = true;
      fullscreen = false;
      inverted-colors = false;
      show-sidebar = true;
      sidebar-page = "thumbnails";
      sidebar-size = 148;
      sizing-mode = "automatic";
      window-ratio = "(0.041666666666666664, 0.07194444444444445)";
    };
    "org/gnome/evolution-data-server" = {
      migrated = true;
    };
    "org/gnome/evolution-data-server/calendar" = {
      reminders-past = "@as []";
    };
    "org/gnome/firmware" = {
      report-device-list-timestamp = "int64 1751300854";
    };
    "org/gnome/gnome-system-monitor" = {
      current-tab = "processes";
      maximized = false;
      show-dependencies = false;
      show-whose-processes = "all";
      window-height = 720;
      window-width = 800;
    };
    "org/gnome/gnome-system-monitor/disktreenew" = {
      col-6-visible = true;
      col-6-width = 0;
    };
    "org/gnome/gnome-system-monitor/proctree" = {
      col-26-visible = false;
      col-26-width = 0;
      columns-order = [  ];
      sort-col = 8;
      sort-order = 0;
    };
    "org/gnome/maps" = {
      last-viewed-location = [  ];
      map-type = "MapsStreetSource";
      osm-username-oauth2 = "bivirus";
      transportation-type = "pedestrian";
      window-maximized = true;
      zoom-level = 7;
    };
    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
      edge-tiling = false;
      experimental-features = [ "variable-refresh-rate" ];
      overlay-key = "Super_L";
      workspaces-only-on-primary = false;
    };
    "org/gnome/mutter/keybindings" = {
      cancel-input-capture = "@as []";
      toggle-tiled-left = "@as []";
      toggle-tiled-right = "@as []";
    };
    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = "@as []";
    };
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };
    "org/gnome/nautilus/window-state" = {
      initial-size = "(890, 550)";
      initial-size-file-chooser = "(890, 1036)";
      maximized = false;
    };
    "org/gnome/nm-applet/eap/23cf13bf-a34a-4049-9214-86d5529ddba0" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };
    "org/gnome/nm-applet/eap/3be38d10-a3ba-3dab-af46-dcba86fbc058" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };
    "org/gnome/nm-applet/eap/79a78bb0-1c29-4363-ab9c-95c02ae17516" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };
    "org/gnome/nm-applet/eap/90fd9d51-4cf6-4d2f-a7c4-5fe3e6265c30" = {
      ignore-ca-cert = true;
      ignore-phase2-ca-cert = false;
    };
    "org/gnome/nm-applet/eap/ae7cbc04-e395-4b0a-813f-830566d8f00c" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };
    "org/gnome/nm-applet/eap/ce5d4ae1-c52e-3085-9b09-d1c0c6ce8864" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };
    "org/gnome/nm-applet/eap/e77c69cd-02e7-4e73-afa4-ea78888b5e92" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };
    "org/gnome/nm-applet/eap/ea80a5ef-e3b4-49f9-8ae9-2023df89ec7e" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };
    "org/gnome/portal/filechooser/app.zen_browser.zen" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/com.brave.Browser" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/com.discordapp.Discord" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/com.usebottles.bottles" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/dev.vencord.Vesktop" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/io.github.zen_browser.zen" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/io.gitlab.adhami3310.Footage" = {
      last-folder-path = "${config.home.homeDirectory}";
    };
    "org/gnome/portal/filechooser/net.lutris.Lutris" = {
      last-folder-path = "${config.home.homeDirectory}/Games";
    };
    "org/gnome/portal/filechooser/org.gnome.Boxes" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/org.gnome.Builder" = {
      last-folder-path = "${config.home.homeDirectory}";
    };
    "org/gnome/portal/filechooser/org.gnome.GHex" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/org.gnome.TextEditor" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/org.gnome.gitlab.somas.Apostrophe" = {
      last-folder-path = "${config.home.homeDirectory}";
    };
    "org/gnome/portal/filechooser/org.videolan.VLC" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/re.rizin.cutter" = {
      last-folder-path = "${config.home.homeDirectory}/Downloads";
    };
    "org/gnome/portal/filechooser/ulauncher" = {
      last-folder-path = "${config.home.homeDirectory}";
    };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-last-coordinates = "(48.117595737382487, 11.586764799999999)";
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = "@as []";
      rotate-video-lock-static = "@as []";
    };
    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = true;
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-battery-type = "suspend";
    };
    "org/gnome/shell" = {
      app-picker-layout = [ "org.gnome.clocks.desktop" "position" "org.gnome.Totem.desktop" "position" "org.gnome.Weather.desktop" "position" "org.gnome.Maps.desktop" "position" "org.gnome.Calculator.desktop" "position" "org.gnome.Geary.desktop" "position" "simple-scan.desktop" "position" "org.gnome.Settings.desktop" "position" "org.gnome.Terminal.desktop" "position" "moe.nyarchlinux.tour.desktop" "position" "moe.nyarchlinux.customize.desktop" "position" "de.haeckerfelix.Shortwave.desktop" "position" "info.febvre.Komikku.desktop" "position" "com.github.tchx84.Flatseal.desktop" "position" "de.haeckerfelix.Fragments.desktop" "position" "org.gnome.Lollypop.desktop" "position" "webapp-manager.desktop" "position" "chromium.desktop""position" "com.mattjakeman.ExtensionManager.desktop" "position" "org.gnome.Tour.desktop" "position" "Utilities" "position" "org.gnome.PackageUpdater.desktop" "position" "org.gnome.Packages.desktop" "position" "pavucontrol.desktop" "position" "org.gnome.TextEditor.desktop" "position" "appimagelaunchersettings.desktop" "position" "yelp.desktop" "position" "htop.desktop" "position" "kitty.desktop" "position" "cups.desktop" "position" "2613ee0d-5a8a-4cb0-9d8e-4594074d5956" "position" "mpv.desktop" "position" "ezmaint.desktop" "position" "gnome-system-monitor.desktop" "position" "org.gnome.Extensions.desktop" "position" ];
      disable-extension-version-validation = true;
      disable-user-extensions = false;
      disabled-extensions = [  ];
      enabled-extensions = [ "blur-my-shell@aunetx" "gsconnect@andyholmes.github.io" "runcat@kolesnikov.se" "drive-menu@gnome-shell-extensions.gcampax.github.com" "yakuake-extension@kde.org" "arcmenu@arcmenu.com" "CustomizeClockOnLockScreen@pratap.fastmail.fm" "just-perfection-desktop@just-perfection" "quick-lofi@eucaue" "reboottouefi@ubaygd.com" "Vitals@CoreCoding.com" "clipboard-indicator@tudmotu.com" "paperwm@paperwm.github.com" "KeepAwake@jepfa.de" "color-picker@tuberry" "appindicatorsupport@rgcjonas.gmail.com" "Rounded_Corners@lennart-k" ];
      favorite-apps = [ "org.gnome.Calendar.desktop" "org.gnome.Nautilus.desktop" "kitty.desktop" "com.spotify.Client.desktop" ];
      last-selected-power-profile = "performance";
      welcome-dialog-last-shown-version = "48.2";
    };
    "org/gnome/shell/extensions/appindicator" = {
      icon-brightness = "0.0";
      icon-contrast = "0.0";
      icon-opacity = 240;
      icon-saturation = "0.0";
      icon-size = 0;
    };
    "org/gnome/shell/extensions/KeepAwake@jepfa.de" = {
      idle-activation-enabled = false;
      idle-delay = 0;
      idle-dim = false;
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
    };
    "org/gnome/shell/extensions/arcmenu" = {
      application-shortcuts = [ "name" "Software" "icon" "org.gnome.Software" "id" "ArcMenu_Software" "name" "Settings" "icon" "org.gnome.Settings" "id" "org.gnome.Settings.desktop" "name" "Tweaks" "icon" "org.gnome.tweaks" "id" "org.gnome.tweaks.desktop" "name" "Activities Overview" "icon" "view-fullscreen-symbolic" "id" "ArcMenu_ActivitiesOverview" "name" "Extension Manager" "icon" "com.mattjakeman.ExtensionManager" "id" "com.mattjakeman.ExtensionManager.desktop" ];
      application-shortcuts-list = "@aas []";
      button-item-icon-size = "Small";
      custom-menu-button-icon-size = "23.0";
      dash-to-panel-standalone = false;
      disable-recently-installed-apps = true;
      distro-icon = 22;
      extra-categories = [  ];
      force-menu-location = "Off";
      highlight-search-result-terms = true;
      hotkey-open-primary-monitor = true;
      max-search-results = 10;
      menu-arrow-rise = "(false, 6)";
      menu-background-color = "#262830";
      menu-border-color = "rgb(60,60,60)";
      menu-button-active-fg-color = "(true, 'rgb(26,95,180)')";
      menu-button-appearance = "Icon";
      menu-button-border-radius = "(true, 25)";
      menu-button-fg-color = "(false, 'rgb(26,95,180)')";
      menu-button-icon = "Distro_Icon";
      menu-button-position-offset = 0;
      menu-foreground-color = "#e0e0e8";
      menu-item-active-bg-color = "#004397";
      menu-item-active-fg-color = " #d6e2ff";
      menu-item-grid-icon-size = "Medium";
      menu-item-hover-bg-color = " #004397";
      menu-item-hover-fg-color = " #d6e2ff";
      menu-layout = "Eleven";
      menu-separator-color = "rgba(255,255,255,0.1)";
      multi-monitor = true;
      override-menu-theme = true;
      pinned-app-list = "@as []";
      pinned-apps = [ "name" "Files" "id" "org.gnome.Nautilus.desktop" ];
      pop-folders-data = "{'Library Home': 'Library Home', 'Utilities': 'Utilities', 'System': 'System'}";
      position-in-panel = "Left";
      power-display-style = "Menu";
      power-options = [  ];
      prefs-visible-page = 0;
      recently-installed-apps = [];
      runner-hotkey-open-primary-monitor = false;
      search-entry-border-radius = "(true, 25)";
      search-provider-open-windows = true;
      search-provider-recent-files = true;
      shortcut-icon-type = "Full_Color";
      show-activities-button = false;
      show-search-result-details = true;
      show-update-notification-v64 = false;
      update-notifier-project-version = 66;
    };
    "org/gnome/shell/extensions/blur-my-shell" = {
      settings-version = 2;
    };
    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = "0.59999999999999998";
      sigma = 30;
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      brightness = "0.59999999999999998";
      sigma = 30;
    };
    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      brightness = "0.59999999999999998";
      sigma = 30;
    };
    "org/gnome/shell/extensions/clipboard-indicator" = {
      cache-size = 256;
      display-mode = 0;
      history-size = 200;
      toggle-menu = [ "<Shift><Super>v" ];
    };
    "org/gnome/shell/extensions/color-picker" = {
      color-history = [  ];
      preview-style = "uint32 1";
    };
    "org/gnome/shell/extensions/gsconnect" = {
      devices = [];
      enabled = true;
      name = "nixos";
      show-indicators = false;
    };
    "org/gnome/shell/extensions/gsconnect/messaging" = {
      window-maximized = false;
      window-size = "(640, 989)";
    };
    "org/gnome/shell/extensions/gsconnect/preferences" = {
      window-maximized = false;
      window-size = "(790, 460)";
    };
    "org/gnome/shell/extensions/just-perfection" = {
      max-displayed-search-results = 0;
      panel-in-overview = true;
      support-notifier-showed-version = 34;
      theme = false;
      workspace-switcher-should-show = false;
      workspace-wrap-around = false;
    };
    "org/gnome/shell/extensions/lennart-k/rounded_corners" = {
      corner-radius = 14;
    };
    "org/gnome/shell/extensions/messagingmenu" = {
      compatible-chats = "amsn;caprine;chat.rocket.RocketChat;im.dino.Dino;emesene;empathy;fedora-empathy;gajim;hexchat;io.github.qtox.qTox;kadu;kde4-kmess;kde4-konversation;kde4-kopete;openfetion;org.gnome.Fractal;org.gnome.Polari;pidgin;qtox;qutim;signal-desktop;skype;skypeforlinux;slack;telegramdesktop;utox;venom;viber;xchat;discord;Zoom;com.discordapp.Discord";
    };
    "org/gnome/shell/extensions/paperwm" = {
      animation-time = "0.19999999999999996";
      cycle-width-steps = [0.38195000000000001 0.5 0.61804000000000003 1.0];
      horizontal-margin = 4;
      last-used-display-server = "Wayland";
      open-window-position = 0;
      restore-attach-modal-dialogs = "true";
      restore-edge-tiling = "true";
      restore-keybinds = "{}";
      restore-workspaces-only-on-primary = "true";
      selection-border-radius-bottom = 14;
      selection-border-radius-top = 14;
      selection-border-size = 4;
      show-window-position-bar = true;
      show-workspace-indicator = false;
      vertical-margin = 6;
      vertical-margin-bottom = 6;
      window-gap = 6;
      winprops = "@as []";
    };
    "org/gnome/shell/extensions/paperwm/keybindings" = {
      switch-next-loop = [ "<Super>Right" ];
      switch-right = [ "" ];
    };
    "org/gnome/shell/extensions/paperwm/workspaces" = {
      list = [ "dee7f8c6-fcb9-468c-989a-5997725f997c" "50de0e8d-319a-4b63-a674-583de3def5c1" "60a3ca08-0524-4546-a314-1bd7ca9b9474" "88249277-7bad-4df2-a51e-04fb0b606557" ];
    };
    "org/gnome/shell/extensions/paperwm/workspaces/50de0e8d-319a-4b63-a674-583de3def5c1" = {
      index = 1;
    };
    "org/gnome/shell/extensions/paperwm/workspaces/60a3ca08-0524-4546-a314-1bd7ca9b9474" = {
      index = 2;
    };
    "org/gnome/shell/extensions/paperwm/workspaces/88249277-7bad-4df2-a51e-04fb0b606557" = {
      index = 3;
    };
    "org/gnome/shell/extensions/paperwm/workspaces/dee7f8c6-fcb9-468c-989a-5997725f997c" = {
      index = 0;
      show-position-bar = true;
      show-top-bar = true;
    };
    "org/gnome/shell/extensions/quick-lofi" = {
      current-radio-playing = "";
      radios = [ "Lofi Girl - https://play.streamafrica.net/lofiradio - wlx|EB=^g<" "Lofi Hunter - https://live.hunter.fm/lofi_high - yUV;c$X7yJ" "Lofi Hip-hop - http://hyades.shoutca.st:8043/stream - aJ}M#=8u@|" ];
      volume = 11;
    };
    "org/gnome/shell/extensions/runcat" = {
      displaying-items = "character-and-percentage";
    };
    "org/gnome/shell/extensions/trayIconsReloaded" = {
      applications = "[{\"id\":\"jetbrains-toolbox.desktop\",\"hidden\":false},{\"id\":\"com.github.hluk.copyq.desktop\",\"hidden\":true},{\"id\":\"ulauncher.desktop\",\"hidden\":false}]";
      icon-margin-horizontal = 0;
      icon-padding-horizontal = 10;
      icon-size = 16;
      icons-limit = 6;
      position-weight = 1;
      tray-margin-left = 0;
    };
    "org/gnome/shell/extensions/vitals" = {
      alphabetize = true;
      battery-slot = 0;
      hide-icons = false;
      hide-zeros = true;
      hot-sensors = ["_memory_usage_" "_processor_usage_" "__network-rx_max__" "_storage_free_" "__temperature_avg__"];
      icon-style = 1;
      include-static-gpu-info = false;
      include-static-info = true;
      menu-centered = true;
      show-battery = false;
      show-fan=false;
      show-gpu = false;
      show-voltage=false;
      update-time = 1;
      use-higher-precision = false;
    };
    "io/github/jeffshee/hanabi-extension" = {
      change-wallpaper = false;
      change-wallpaper-interval = 25;
      content-fit = 0;
      debug-mode = false;
      enable-va = true;
      force-gtk4paintablesink = false;
      force-mediafile = false;
      low-battery-threshold = 20;
      mute = true;
      show-panel-menu = true;
      video-path = "${config.home.homeDirectory}/Downloads/106557-673518279_small.mp4";
      volume=50;
    };
    "org/gnome/shell/extensions/top-bar-organizer" = {
      right-box-order=["quick-lofi@eucaue" "color-picker@tuberry" "messageMenu" "runcat-indicator" "vitalsMenu" "clipboardIndicator" "screenRecording" "screenSharing" "dwellClick" "a11y" "keyboard" "quickSettings"];
      left-box-order = ["ArcMenu" "WorkspaceMenu" "FocusButton" "OpenPositionButton" "activities"];
      center-box-order = ["dateMenu"];
    };

    "org/gnome/shell/keybindings" = {
      focus-active-notification = "@as []";
      shift-overview-down = "@as []";
      shift-overview-up = "@as []";
      toggle-message-tray = "@as []";
    };
    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = [ "Halifax" "CYHZ" "Munich" "EDDM" ];
    };
    "org/gnome/shell/world-clocks" = {
      locations = [ "Halifax" "CYHZ" ];
    };
    "org/gnome/system/location" = {
      enabled = true;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };
    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [  ];
      selected-color = "(true, 1.0, 0.0, 0.0, 1.0)";
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
      window-size = "(859, 718)";
    };
    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 175;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = "(717, 44)";
      window-size = "(1203, 989)";
    };
  };
}
