# Zsh — the interactive shell (core).
#
# Enables zsh with completion, autosuggestions, syntax-highlighting and history.
# Everything else is split into sibling files: aliases (general), init
# (interactive .zshrc), profile (login shell). Program-specific aliases live in
# their own files (e.g. `wifi` in cli/nmtui-go.nix, `oc` in ai/opencode.nix).
{ config, ... }:
{
  imports = [
    ./aliases.nix
    ./functions.nix
    ./init.nix
    ./profile.nix
  ];

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true;
    history = {
      append = true;
      extended = true;
    };
    syntaxHighlighting.enable = true;
  };
}
