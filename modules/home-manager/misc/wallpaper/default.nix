{ lib, ... }:
{
  options.wallpaper = lib.mkOption {
    type = lib.types.path;
    default = ./wallpaper-2.jpeg;
    readOnly = true;
    description = "Path to default wallpaper";
  };
}
