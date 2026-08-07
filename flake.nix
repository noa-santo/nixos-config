{
  description = "The NixOS config of u200b";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-jetbrains-plugins.url = "github:theCapypara/nix-jetbrains-plugins";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    niri = {
      url = "github:epireyn/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix.url = "github:nix-community/fenix";
    niri-screen-time.url = "github:probeldev/niri-screen-time";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emojidb-extension = {
      url = "github:noa-santo/vicinae-emojidb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
      pkgs = import nixpkgs {
        inherit system lib;
        config.allowUnfree = true;
        overlays = [
          inputs.nix-minecraft.overlay
          inputs.fenix.overlays.default
          inputs.niri.overlays.niri
        ]
        ++ map (file: import (./overlays + "/${file}")) (
          builtins.filter (file: lib.hasSuffix ".nix" file) (builtins.attrNames (builtins.readDir ./overlays))
        );
      };
      hosts = builtins.attrNames (builtins.readDir ./hosts);

      mkHost =
        host:
        let
          tagsPath = ./hosts/${host}/tags.nix;
          hostTags = if builtins.pathExists tagsPath then import tagsPath else [ ];
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs hostTags; };
          modules = [
            ./hosts/${host}/configuration.nix
            { nixpkgs = { inherit pkgs; }; }
            ./hosts/${host}/hardware-configuration.nix
            inputs.nix-minecraft.nixosModules.minecraft-servers
            inputs.niri.nixosModules.niri
            inputs.stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs hostTags; };
              };
            }
            ({ config, ... }: {
              home-manager.users."${config.mainUser}" = import ./hosts/${host}/home.nix;
            })
          ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs hosts mkHost;

      devShells.${system} = builtins.listToAttrs (
        map
          (file: {
            name = lib.removeSuffix ".nix" file;
            value = import (./dev-shells + "/${file}") { inherit pkgs inputs; };
          })
          (
            builtins.filter (file: lib.hasSuffix ".nix" file) (
              builtins.attrNames (builtins.readDir ./dev-shells)
            )
          )
      );

      formatter.x86_64-linux = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
