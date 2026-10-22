# whisper — local speech-to-text.
#
# Provides two wrappers around whisper.cpp (Vulkan, for the AMD iGPU):
#   - `whisper <audio-file>`  transcribe a file (converts to 16k mono WAV first)
#   - `whisper-live`          real-time transcription from the microphone
#
# Two models are fetched declaratively into the store:
#   - small (DEFAULT / best all-round): fast on the iGPU, accurate enough for
#     most cases.
#   - large-v3-turbo: higher accuracy, bigger/slower. Use with
#     `WHISPER_MODEL=large`.
{ pkgs, ... }:
let
  smallModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small-q8_0.bin";
    hash = "sha256-Scj7ArZeYEnV+mwE+B9TuGe17JVAQGgSxkPxdzF/d58=";
  };

  largeModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q8_0.bin";
    hash = "sha256-MX62nBFnPJ3h4fDUWbJTmZgE7HGsTCPBfs9fviTiWaE=";
  };

  whisperWrapper = pkgs.writeShellScriptBin "whisper" ''
    set -euo pipefail
    model="${smallModel}"
    if [ "''${WHISPER_MODEL:-small}" = "large" ]; then
      model="${largeModel}"
    fi
    if [ "$#" -eq 0 ]; then
      echo "usage: whisper <audio-or-video-file> [extra whisper-cli args...]" >&2
      exit 1
    fi
    input="$1"; shift
    wav="$(mktemp --suffix=.wav)"
    trap 'rm -f "$wav"' EXIT
    ${pkgs.ffmpeg}/bin/ffmpeg -loglevel error -y -i "$input" -ar 16000 -ac 1 -c:a pcm_s16le "$wav"
    exec ${pkgs.whisper-cpp-vulkan}/bin/whisper-cli -m "$model" -f "$wav" "$@"
  '';

  whisperLive = pkgs.writeShellScriptBin "whisper-live" ''
    model="${smallModel}"
    if [ "''${WHISPER_MODEL:-small}" = "large" ]; then
      model="${largeModel}"
    fi
    exec ${pkgs.whisper-cpp-vulkan}/bin/whisper-stream -m "$model" "$@"
  '';
in
{
  home.packages = [
    pkgs.whisper-cpp-vulkan
    whisperWrapper
    whisperLive
  ];
}
