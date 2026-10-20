# Neovim — the main editor (LazyVim).
#
# `v`/`vim`/`vi` are aliased to nvim. Config lives in ./neovim/lazyvim (the
# full LazyVim tree). `extraPackages` holds the language servers / linters /
# formatters used by the LSP and conform; treesitter ships with all grammars.
{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    extraPython3Packages = ps: with ps; [
      jupyter
      pynvim
      jupyter-client
      ipykernel
    ];

    plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];

    extraPackages = with pkgs; [
      tree-sitter
      gcc
      gnumake

      black
      golangci-lint
      gopls
      gotools
      hadolint
      isort
      lua-language-server
      markdownlint-cli
      nixd
      nixfmt
      bash-language-server
      prettier
      pyright
      ruff
      shellcheck
      shfmt
      stylua
      vscode-langservers-extracted
      yaml-language-server

      python3Packages.jupyter
      python3Packages.pynvim
      python3Packages.jupyter-client
      python3Packages.ipykernel

      imagemagick
      ffmpeg
      chafa

      readline
      lua5_1
      luarocks

      hunspell
      hunspellDicts.en_US
    ];
  };

  home.file.".local/share/nvim/dict/words".source = "${pkgs.scowl}/lib/aspell/en-common.wl";

  xdg.configFile = {
    "nvim" = {
      source = ./neovim/lazyvim;
      recursive = true;
    };
  };

  programs.zsh.shellAliases = {
    v = "nvim";
    vi = "nvim";
    vim = "nvim";
  };
}
