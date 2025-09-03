{ lib, ... }:
{
  options.wallpaper = lib.mkOption {
    type = lib.types.path;
    default = ./space.png;
    readOnly = true;
    description = "Path to default wallpaper";
  };
}
