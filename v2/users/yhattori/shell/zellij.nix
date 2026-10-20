# Zellij — terminal multiplexer (tmux-like).
#
# `main` alias attaches to the always-running session. Config and theme live in
# ./zellij/ (config.kdl + catppuccin.kdl). Kitty graphics protocol is enabled so
# yazi/neovim image previews work inside panes.
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
    "zellij/config.kdl".source = ./zellij/config.kdl;
    "zellij/themes/catppuccin.kdl".source = ./zellij/catppuccin.kdl;
  };

  programs.zsh.shellAliases.main = "zellij attach --create main";
}
