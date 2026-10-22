# Zsh — shell functions (multi-step commands + help).
#
# Multi-command helpers that don't fit the single-short-command alias model,
# plus a `help` function that prints the full alias/function cheat-sheet,
# grouped by topic.
{ constants, lib, ... }:
{
  programs.zsh.initContent = lib.mkAfter ''
    upfw() { cd ${constants.nixConfigDir} && sudo nixos-rebuild switch --flake .#framework13; }
    uphm() { cd ${constants.nixConfigDir} && home-manager switch --flake .#yhattori@framework13 -b backup && niri msg action load-config-file; }
    upall() { upfw && uphm; }
    update-bios() { fwupdmgr refresh --force && fwupdmgr get-updates && fwupdmgr update; }

    help() {
      echo "shell:"
      echo "  main            zellij attach --create main"
      echo "  ff              fastfetch"
      echo "  cd              z (zoxide)"
      echo "  ls/ll/la/lt     eza (icons/long/all/tree)"
      echo ""
      echo "network:"
      echo "  wifi            nmtui-go"
      echo "  bt              bluetui"
      echo ""
      echo "dev:"
      echo "  lg              lazygit"
      echo "  v/vi/vim        nvim"
      echo ""
      echo "ai:"
      echo "  oc              opencode"
      echo ""
      echo "python:"
      echo "  conda/mamba     micromamba"
      echo "  deeplearning    conda activate deeplearning"
      echo ""
      echo "apps:"
      echo "  sunshine-ui     sunshine web UI in zen"
      echo ""
      echo "navigation:"
      echo "  repo            cd ~/Documents/repositories"
      echo "  temp            cd ~/Downloads/temp"
      echo "  ..              cd .."
      echo ""
      echo "functions:"
      echo "  upfw            rebuild system (nixos-rebuild)"
      echo "  uphm            rebuild home-manager"
      echo "  upall           upfw + uphm"
      echo "  update-bios     fwupdmgr update"
    }
  '';
}
