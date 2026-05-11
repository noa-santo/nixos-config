{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    withRuby = false;
    withPython3 = false;

    extraPackages = with pkgs; [
      ripgrep
      fd
      lua-language-server
      pyright
      nil
      nixpkgs-fmt
    ];

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      nvim-web-devicons
      nvim-treesitter.withAllGrammars
      lualine-nvim
      bufferline-nvim
      indent-blankline-nvim
      gitsigns-nvim
      which-key-nvim
      nvim-tree-lua
      telescope-nvim
      telescope-ui-select-nvim
      nvim-autopairs
      comment-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets
    ];
  };

  # Symlink init.lua out-of-store so edits take effect without rebuilding.
  xdg.configFile."init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/home-modules/shell/nvim/init.lua";
}