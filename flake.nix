{
 description = "The NixOS config of u200b";

 inputs = {
   nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
   home-manager.url = "github:nix-community/home-manager";
   home-manager.inputs.nixpkgs.follows = "nixpkgs";
   zen-browser.url = "github:MarceColl/zen-browser-flake";
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
   in {
     nixosConfigurations = {
       main = lib.nixosSystem {
         inherit system;
         specialArgs = { inherit inputs; };
         modules = [
           ./hosts/main/configuration.nix { nixpkgs = { inherit pkgs; }; }
           ./hosts/main/hardware-configuration.nix
           inputs.nix-minecraft.nixosModules.minecraft-servers

           home-manager.nixosModules.home-manager
           {
             home-manager.useGlobalPkgs = true;
             home-manager.useUserPackages = true;
             home-manager.backupFileExtension = "backup";
             home-manager.users.u200b = import ./hosts/main/home.nix { inherit pkgs; };
           }
         ];
       };
       dell = lib.nixosSystem {
         inherit system;
         specialArgs = { inherit inputs; };
         modules = [
           ./hosts/dell/configuration.nix { nixpkgs = { inherit pkgs; }; }
           ./hosts/dell/hardware-configuration.nix
           inputs.nix-minecraft.nixosModules.minecraft-servers

           home-manager.nixosModules.home-manager
           {
             home-manager.useGlobalPkgs = true;
             home-manager.useUserPackages = true;
             home-manager.backupFileExtension = "backup";
             home-manager.users.owo = import ./hosts/dell/home.nix { inherit pkgs; };
           }
         ];
       };
     };
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
