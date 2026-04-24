{
  outputs,
  userConfig,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/aerospace
    # ../programs/albert
    ../programs/atuin
    ../programs/bat
    ../programs/btop
    ../programs/codex
    ../programs/fastfetch
    ../programs/fzf
    ../programs/gemini-cli
    ../programs/ghostty
    ../programs/git
    ../programs/go
    ../programs/gpg
    ../programs/k9s
    ../programs/krew
    ../programs/lazygit
    ../programs/neovim
    ../programs/mpv
    ../programs/obs-studio
    ../programs/saml2aws
    ../programs/starship
    ../programs/zellij
    ../programs/zoxide
    ../programs/zsh
    ../programs/zathura
    ../programs/zen-browser
    ../programs/python
    ../programs/vscode
    ../scripts
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
    homeDirectory =
      if pkgs.stdenv.isDarwin then "/Users/${userConfig.name}" else "/home/${userConfig.name}";
  };

  # Ensure common packages are installed
  home.packages =
    with pkgs;
    [
      aider-chat
      anki-bin
      awscli2
      dig
      discord-ptb
      dust
      eza
      fd
      jq
      kubectl
      lazydocker
      nh
      opencode
      openconnect
      networkmanagerapplet
      pipenv
      playerctl
      ripgrep
      terraform
      obsidian
      spotify
      google-chrome
      gimp3
      inkcut
      inkscape
      micromamba
      stdenv.cc.cc.lib
      swaybg
      zlib
    ]
    ++ lib.optionals stdenv.isDarwin [
      colima
      docker
      hidden-bar
      mos
      raycast
    ]
    ++ lib.optionals (!stdenv.isDarwin) [
      # Wifi
      impala
      tesseract
      unzip
      vlc
      celluloid
      imv
      kdePackages.gwenview
      shotwell
      wl-clipboard
    ];

  # Catpuccin flavor and accent
  catppuccin = {
    flavor = "mocha";
    accent = "lavender";
  };
}
