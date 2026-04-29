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
 };

 outputs = { self, nixpkgs, home-manager, ... }@inputs:
   let
     system = "x86_64-linux";
     lib = nixpkgs.lib;
     pkgs = import nixpkgs {
      inherit system lib;
      config.allowUnfree = true;
      overlays = [
        inputs.nix-minecraft.overlay
      ] ++ builtins.map
        (file: import (./overlays + "/${file}"))
        (builtins.filter
          (file: lib.hasSuffix ".nix" file)
          (builtins.attrNames (builtins.readDir ./overlays)));
     };
     hosts = builtins.attrNames (builtins.readDir ./hosts);

     mkHost = host: lib.nixosSystem {
       inherit system;
       specialArgs = { inherit inputs; };
       modules = [
         ./hosts/${host}/configuration.nix { nixpkgs = { inherit pkgs; }; }
         ./hosts/${host}/hardware-configuration.nix
         inputs.nix-minecraft.nixosModules.minecraft-servers

         home-manager.nixosModules.home-manager
         {
           home-manager.useGlobalPkgs = true;
           home-manager.useUserPackages = true;
           home-manager.backupFileExtension = "backup";
           home-manager.extraSpecialArgs = { inherit inputs; };
         }
         ({ config, ... }: {
           home-manager.users."${config.mainUser}" = import ./hosts/${host}/home.nix;
         })
       ];
     };
   in {
     nixosConfigurations = lib.genAttrs hosts mkHost;

     devShells.${system} = builtins.listToAttrs (map
       (file: {
         name = lib.removeSuffix ".nix" file;
         value = import (./dev-shells + "/${file}") { inherit pkgs; };
       })
       (builtins.filter
         (file: lib.hasSuffix ".nix" file)
         (builtins.attrNames (builtins.readDir ./dev-shells))));
  };
}
