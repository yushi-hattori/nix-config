{ pkgs, ... }:
{
  # Neovim text editor configuration
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    extraPython3Packages = ps: with ps; [
      jupyter
      pynvim # Neovim Remote Plugin API
      jupyter-client # For interacting with Jupyter kernels
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
      nodePackages.bash-language-server
      nodePackages.prettier
      pyright
      ruff
      shellcheck
      shfmt
      stylua
      terraform-ls
      tflint
      vscode-langservers-extracted
      yaml-language-server

      # Python packages for molten-nvim and Jupyter integration
      python3Packages.jupyter
      python3Packages.pynvim # Neovim Remote Plugin API
      python3Packages.jupyter-client # For interacting with Jupyter kernels
      python3Packages.ipykernel

      # imagemagick for image.nvim
      imagemagick

      # readline for luarocks Lua compilation
      readline
      lua5_1
      luarocks # Provide pre-built luarocks
    ];
  };

  # source lua config from this repo
  xdg.configFile = {
    "nvim" = {
      source = ./lazyvim;
      recursive = true;
    };
  };
}
