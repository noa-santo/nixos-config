{pkgs, ...}:
let
  pythonDesktop = pkgs.makeDesktopItem {
    name = "python-ide";
    exec = "python-ide";
    icon = "python";
    desktopName = "PyCharm (Python Env)";
    comment = "Start PyCharm with Python dev environment";
    categories = [ "Development" ];
  };
  vDesktop = pkgs.makeDesktopItem {
      name = "vlang-ide";
      exec = "vlang-ide";
      icon = "vlang";
      desktopName = "CLion (V Env)";
      comment = "Start CLion with V dev environment";
      categories = [ "Development" ];
    };
    tsDesktop = pkgs.makeDesktopItem {
      name = "typescript-ide";
      exec = "typescript-ide";
      icon = "typescript";
      desktopName = "Webstorm (Typescript Env)";
      comment = "Start Webstorm with Typescript dev environment";
      categories = [ "Development" ];
    };
    mcModDesktop = pkgs.makeDesktopItem {
          name = "minecraft-mods-ide";
          exec = "minecraft-mods-ide";
          icon = "idea";
          desktopName = "InteliJ (Minecraft Mods Env)";
          comment = "Start InteliJ with Minecraft modding dev environment";
          categories = [ "Development" ];
        };
in {
  home.packages = [
    pythonDesktop
    vDesktop
    tsDesktop
    mcModDesktop
  ];
}
