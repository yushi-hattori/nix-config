{ lib, ... }:
{
  options.wallpaper = lib.mkOption {
    type = lib.types.path;
    default = ../../../../files/wallpapers/nix-wallpaper.png;
    readOnly = true;
    description = "Path to default wallpaper";
  };
}
