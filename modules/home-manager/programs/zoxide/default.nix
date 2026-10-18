{ lib, pkgs, ... }:
{
  programs.zoxide = {
    enable = true;
    # zsh integration is handled manually below so it loads last; see note.
    enableZshIntegration = false;
    enableBashIntegration = true;
  };

  # zoxide installs a precmd hook and its doctor warns unless that hook is the
  # LAST entry in precmd_functions. Home-manager inits zoxide early (before the
  # user initContent and before starship), so starship's precmd ends up last and
  # trips the warning. Re-init zoxide after everything else — mkOrder 2000 lands
  # after starship's mkAfter (1500) — so __zoxide_hook is registered last.
  programs.zsh.initContent = lib.mkOrder 2000 ''
    eval "$(${lib.getExe pkgs.zoxide} init zsh)"
  '';
}
