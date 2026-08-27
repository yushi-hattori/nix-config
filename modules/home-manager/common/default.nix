{
  outputs,
  userConfig,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/atuin
    ../programs/bat
    ../programs/btop
    ../programs/codex
    ../programs/fastfetch
    ../programs/fzf
    ../programs/antigravity-cli
    ../programs/ghostty
    ../programs/git
    ../programs/go
    ../programs/gpg
    ../programs/lazygit
    ../programs/neovim
    ../programs/mpv
    ../programs/obs-studio
    ../programs/starship
    ../programs/zellij
    ../programs/zoxide
    ../programs/zsh
    ../programs/zathura
    ../programs/zen-browser
    ../programs/python
    ../programs/vscode
    ../scripts
    ../services/easyeffects
    ../services/flatpak
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Home-Manager configuration for the user's home environment
  home = {
    username = "${userConfig.name}";
    homeDirectory = "/home/${userConfig.name}";
  };

  # Ensure common packages are installed
  home.packages = with pkgs; [
    aider-chat
    dig
    discord-ptb
    dust
    eza
    fd
    herdr
    jq
    lazydocker
    nh
    nixfmt
    opencode
    openconnect
    pipenv
    playerctl
    ripgrep
    yazi
    obsidian
    spotify
    google-chrome
    gimp3
    inkcut
    inkscape
    prusa-slicer
    micromamba
    stdenv.cc.cc.lib
    wget
    zlib
    tesseract
    unzip
    vlc
    celluloid
    imv
    shotwell
    wl-clipboard
  ];

  # Catpuccin flavor and accent
  catppuccin = {
    flavor = "mocha";
    accent = "lavender";
  };
}
