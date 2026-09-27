{ pkgs, ... }:

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
      tree-sitter
      lua-language-server
      pyright
      nil
      nixpkgs-fmt
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-web-devicons
      nvim-treesitter.withAllGrammars
      render-markdown-nvim
      lualine-nvim
      bufferline-nvim
      indent-blankline-nvim
      gitsigns-nvim
      which-key-nvim
      neogit
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
      mini-nvim
    ];

    initLua = builtins.readFile ./init.lua;
  };
}
