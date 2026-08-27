{ lib, ... }:
{
  options.wallpaper = lib.mkOption {
    type = lib.types.path;
    default = ../../../../files/wallpapers/wallpaper.jpg;
    readOnly = true;
    description = "Path to default wallpaper";
  };
}
