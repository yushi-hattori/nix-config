# zathura — PDF viewer.
#
# Minimal vim-keyed PDF reader. Recolors pages to match a dark theme and copies
# selections to the clipboard.
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
}
