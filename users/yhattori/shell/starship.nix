# Starship — the shell prompt.
#
# A fast, minimal prompt. The `ff` alias (fastfetch) prints the system banner;
# this is the inline prompt you see on every command.
{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      directory = {
        style = "bold lavender";
      };
      docker_context = { symbol = " "; };
      golang = { symbol = " "; };
      gradle = { symbol = " "; };
      java = { symbol = " "; };
      kotlin = { symbol = " "; };
      lua = { symbol = " "; };
      package = { symbol = " "; };
      php = { symbol = " "; };
      python = { symbol = " "; };
      rust = { symbol = " "; };
    };
  };
}
