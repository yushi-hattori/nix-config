{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Catppuccin Mocha";
      command = "zellij attach --create main";
      window-decoration = false;

      # Window management settings for multi-monitor support
      window-save-state = "never";
      window-step-resize = false;
      gtk-single-instance = false;

      # font-size = 10;
      # keybind = [
      #   "ctrl+h=goto_split:left"
      #   "ctrl+l=goto_split:right"
      # ];
    };
  };
}
