# zoxide — smarter `cd`.
#
# `cd` is aliased to `z` in zsh, so `z proj` jumps to the most-used matching
# directory. Re-inited last (mkOrder 2000) so its precmd hook loads after
# starship's and avoids the "hook not last" warning.
{ lib, pkgs, ... }:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
    enableBashIntegration = true;
  };

  programs.zsh.initContent = lib.mkOrder 2000 ''
    eval "$(${lib.getExe pkgs.zoxide} init zsh)"
  '';

  programs.zsh.shellAliases."cd" = "z";
}
