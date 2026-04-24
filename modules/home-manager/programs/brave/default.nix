{
  pkgs,
  ...
}:
{
  # Ensure Brave browser package installed
  home.packages = [ pkgs.brave ];
}
