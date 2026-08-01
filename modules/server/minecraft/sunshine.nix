# tags: sunshine
# todo: add "server" and "minecraft" tag
{ pkgs, ... }:

let
  mods = pkgs.linkFarm "minecraft-sunshine-mods" [
    {
      name = "TouchController-0.3.1-alpha13+fabric.jar";
      path = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/U7KwGAnT/versions/WbWorlsi/TouchController-0.3.1-alpha13%2Bfabric.jar";
        sha512 = "e6880390f477a476d012d1447437cc4bf2f94831e2eb62dfdf78ab6c4252dbc00df9a7bee4128500566fe17975b54250a01718420efb87d62c7c7d077fdc2d96";
      };
    }
    {
      name = "fabric-api-0.155.2+26.2.jar";
      path = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/lVXlbH4w/fabric-api-0.155.2%2B26.2.jar";
        sha512 = "cc56984378a27c5bcd56374d6ffbb27a45c6bf3355add2ac6be9817ccac5854362249bf9d0147eb271a70fda2716129204e240d53c9aa876a2a7861f4c7f880f";
      };
    }
    {
      name = "fabric-language-kotlin-1.13.13+kotlin.2.4.10.jar";
      path = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/bdhiINYC/fabric-language-kotlin-1.13.13%2Bkotlin.2.4.10.jar";
        sha512 = "9a63c35a550b0362b7b25ff045d93709c7b0dae08c89076cba422813fdfb9e5f5dd021ed3afac9f82e74e95b88c249e8f68b240717151540ca3e88cc27fb9c77";
      };
    }
    {
      name = "modmenu-20.0.1.jar";
      path = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/mOgUt4GM/versions/njXb639R/modmenu-20.0.1.jar";
        sha512 = "1aa297ab5e6fac71ad6af750fe6f8cd25281bd00c0340e5fe1c1e9d153d1198df03be1df55727a4a2116db97dcaad541d41754f3fc0063abfe4345b60f193fb4";
      };
    }
    {
      name = "placeholder-api-3.1.0-beta.1+26.2.jar";
      path = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/eXts2L7r/versions/NDqH16LT/placeholder-api-3.1.0-beta.1%2B26.2.jar";
        sha512 = "07b6fc802559d54ec6577f6e2788926ef391d755206c2bfb0528280977885cae4bc0c517d8a53eb6f34092015ebe6c41210627d255aa6504662daefa8fb76397";
      };
    }
    {
      name = "blazesdl-0.1.11.jar";
      path = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/QDgSARKw/versions/JNa9DOCI/blazesdl-0.1.11.jar";
        sha512 = "b16c4fd16365d681a5c35b2fa5c80a9f8e1fc9c12d18005a62297aa8eaa25d8cbf73325cdd8a758f5429ba5a865b6ebcfc7ac8547dd0138fe8fe282ba0742867";
      };
    }
  ];

  runtimeLibs = pkgs.lib.makeLibraryPath [
    pkgs.wayland
    pkgs.libinput
    pkgs.libxkbcommon
    pkgs.libGL
    pkgs.stdenv.cc.cc.lib
    pkgs.libx11
    pkgs.libxcursor
    pkgs.libxrandr
  ];

  mcVersion = "fabric:26.2";
  workDir = "$HOME/.minecraft-sunshine";

  launchMinecraft = pkgs.writeShellScript "launch-sunshine-mc" ''
    mkdir -p "${workDir}/mods"
    rm -f "${workDir}/mods"/*.jar
    ln -sf ${mods}/*.jar "${workDir}/mods/"
    export LD_LIBRARY_PATH="${runtimeLibs}:''${LD_LIBRARY_PATH:-}"
    ${pkgs.portablemc}/bin/portablemc --main-dir "${workDir}" start "${mcVersion}"
  '';
in
{
  environment.systemPackages = [ pkgs.portablemc ];

  services.sunshine.applications = {
    apps = [
      {
        name = "Minecraft";
        cmd = launchMinecraft;
        auto-detach = "true";
        output = "${workDir}/sunshine.log";
      }
    ];
  };
}
