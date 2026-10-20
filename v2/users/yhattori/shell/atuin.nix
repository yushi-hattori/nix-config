# Atuin — shell history.
#
# Replaces Ctrl-R with a searchable, optionally-synced command history.
# `--disable-up-arrow` keeps the up arrow on plain zsh history while Ctrl-R
# (and the up-arrow UI) go through atuin's fuzzy history search.
{ ... }:
{
  programs.atuin = {
    enable = true;
    settings = {
      inline_height = 25;
      invert = true;
      records = true;
      search_mode = "skim";
      secrets_filter = true;
      style = "compact";
    };
    flags = [ "--disable-up-arrow" ];
  };
}
