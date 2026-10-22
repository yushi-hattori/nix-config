# Ghostty — the terminal emulator.
#
# The GUI window that hosts zsh (inside zellij). `command` auto-attaches to the
# `main` zellij session on launch, so opening a terminal drops you straight into
# the workspace.
{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Catppuccin Mocha";
      command = "zellij attach --create main";
      window-decoration = false;

      window-save-state = "never";
      window-step-resize = true;
      window-padding-x = 0;
      window-padding-y = 0;
      term = "xterm-256color";
      gtk-single-instance = false;
    };
  };
}
