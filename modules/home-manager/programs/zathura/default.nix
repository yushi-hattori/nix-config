{ ... }:
{
  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      recolor-keephue = true;
      selection-clipboard = "clipboard";
    };
  };

  # Enable catppuccin theming for zathura.
  catppuccin.zathura.enable = true;
}
