{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Catppuccin Mocha";
      command = "zellij attach --create main";

      # Window management settings for multi-monitor support
      window-save-state = "never";
      gtk-single-instance = false;

      # font-size = 10;
      # keybind = [
      #   "ctrl+h=goto_split:left"
      #   "ctrl+l=goto_split:right"
      # ];
    };
  };
}
