{
  outputs,
  userConfig,
  pkgs,
  ...
}:
let
  # Speech-to-text model for whisper.cpp, fetched declaratively into the store.
  # large-v3-turbo-q8_0: ~large-v3 accuracy, ~8x faster decoder, quantized to fit
  # the Framework 13 AMD iGPU (Vulkan) comfortably.
  whisperModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q8_0.bin";
    hash = "sha256-MX62nBFnPJ3h4fDUWbJTmZgE7HGsTCPBfs9fviTiWaE=";
  };

  # `whisper <audio-file>` — converts any input to 16kHz mono WAV, then transcribes.
  whisperWrapper = pkgs.writeShellScriptBin "whisper" ''
    set -euo pipefail
    if [ "$#" -eq 0 ]; then
      echo "usage: whisper <audio-or-video-file> [extra whisper-cli args...]" >&2
      exit 1
    fi
    input="$1"; shift
    wav="$(mktemp --suffix=.wav)"
    trap 'rm -f "$wav"' EXIT
    ${pkgs.ffmpeg}/bin/ffmpeg -loglevel error -y -i "$input" -ar 16000 -ac 1 -c:a pcm_s16le "$wav"
    exec ${pkgs.whisper-cpp-vulkan}/bin/whisper-cli -m ${whisperModel} -f "$wav" "$@"
  '';

  # `whisper-live` — real-time transcription from the microphone.
  whisperLive = pkgs.writeShellScriptBin "whisper-live" ''
    exec ${pkgs.whisper-cpp-vulkan}/bin/whisper-stream -m ${whisperModel} "$@"
  '';
in
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
    bluetui
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
    nmtui-go
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
    shotwell
    wl-clipboard
    whisper-cpp-vulkan
    whisperWrapper
    whisperLive
  ];

  # Catpuccin flavor and accent
  catppuccin = {
    flavor = "mocha";
    accent = "lavender";
  };
}
