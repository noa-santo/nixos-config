# nixos-config

This is my personal nixos config. Feel free to look around and check out how I have configured things.
However, this config is pretty specific for my needs so just using it yourself as is will probably not work :p

### Structure

This repo should be in the location `~/.config/nixos-config/`.
Parts of the config rely on that.

```
.
├── dev-shells # auto imported dev shells for different languages and their IDEs
├── flake.lock
├── flake.nix
├── home-modules # user space configs 
│   ├── all.nix # auto importer respecting tags and exclude comments
│   ├── desktop # user space desktop env config 
│   │   └── waybar # waybar config 
│   ├── shell # shell config 
│   └── theming # user specific themeing 
├── hosts # host specific configs 
├── modules # system wide configs for stuff
│   ├── all.nix # auto importer respecting tags and exclude comments
│   ├── apps # system wide apps 
│   └── desktop # system wide configs for desktop enviroments
├── overlays # automatically imported and applied overlays
└── assets # assets for themeing (custom cursor)
```