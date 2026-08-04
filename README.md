# nixos-config

This is my personal nixos config. Feel free to look around and check out how I have configured things. However, this
config is pretty specific for my needs, so just using it yourself as is will probably not work :p

### Structure

This repo should be in the location `~/.config/nixos-config/`. Parts of the config rely on that.

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

### Custom Commands

`rebuild`: automatically rebuilds the system from the nixos config for the main user

`rebuild-fast`: same as `rebuild` but with extensive community caches

`rebuild-reboot`: same as `rebuild` but it defers the switch to the next boot; when everything is ready it will prompt
to reboot automatically

`update`: update all packages. requires a rebuild to apply

`cleanup`: remove old unused nix os stuff. optionally accepts a time range like "day", "week", "month", or "year" and
optionally a quantifier before it. example usage: "cleanup 3 months", "cleanup day", "cleanup"

`tmp`: execute a command without installing it. it automatically detects unfree packages and allows them. example:
`tmp tree` executes the tree command without it being installed. note: may fail if the package name and command name
differ

`tnl`: creates a temporary nix shell with the given package. example: `tnl ffmpeg`

`pasteimg`: pastes an image from the clipboard into a file with a given name

`cf`: copies files selected in a tui into the clipboard

`remote-run`: _see waypipe section_

### waypipe

You can add the `waypipe` tag to your hosts to enable the `remote-run` command.

It lets you run programs on a remote host while having the window appear like a native one on your local machine. This
is useful if you for example want to safe a lil bit of RAM by running the browser on a different host but still have it
appear like a native window on your local machine. The only thing that is required is that your private key is added to
the authorized keys of the host.

**Basic usage**: `remote-run <command>` opens the window on the first host in the network that has the `waypipe` and
`server` tag as well as an authorized ssh connection. The command will automatically figure out the correct username for
that host.

**Advanced usage**:

- `remote-run <host> <command>` opens the window on the specified host. The command will automatically figure out the
  correct username for that host.
- `remote-run <user>@<host> <command>` opens the window on the specified host with the specified user.

Note: `remote-run` will not recognize the local hostname as a host because it excludes the local host from the list of
available ones.

### Tag system

Different host machines require different packages. For example, a server needs a different set of packages than a
laptop. Also, you may want to use Gnome on one device but Sway on another.

For that reason I made a tag system in my config.

In `./hosts/<host>/tags.nix` you can set a list of tags. The auto importer in the `all.nix` files then only import files
automatically that have no tags or only matching tags.

The tags of a file are configured in a comment in the first line with the following syntax:

`# tags: <tag1>, <tag2>, ...`

To exclude a file from being imported automatically, you can put the following comment in the first line:

`# no-auto-import`
