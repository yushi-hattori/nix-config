{ ... }:
{
  # Source scripts from the home-manager store.
  # ~/.local/bin lands on PATH via NixOS's environment.localBinInPath.
  home.file = {
    ".local/bin" = {
      recursive = true;
      source = ./bin;
    };
  };
}
