{ ... }:
{
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      show_startup_tips = false;
      pane_frames = false;
      default_shell = "zsh";
      ui = {
        pane_frames = {
          rounded_corners = true;
        };
      };
    };
  };

  xdg.configFile = {
    "zellij/config.kdl" = {
      source = ./config.kdl;
    };
    "zellij/themes/catppuccin.kdl" = {
      source = ./catppuccin.kdl;
    };
  };
}
