{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Catppuccin Mocha";
      command = "zellij attach --create main";
      # font-size = 10;
      # keybind = [
      #   "ctrl+h=goto_split:left"
      #   "ctrl+l=goto_split:right"
      # ];
    };
  };
}
