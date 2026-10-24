# Zsh — shell functions (multi-step commands + help).
#
# Multi-command helpers that don't fit the single-short-command alias model,
# plus a `help` function that prints the full alias/function cheat-sheet,
# grouped by topic.
{ constants, lib, ... }:
{
  programs.zsh.initContent = lib.mkAfter ''
    # Copy the live DMS settings into the repo so home-manager can keep it
    # declarative (see users/yhattori/desktop/dms.nix). Run before every uphm.
    dms-pull() {
      local src dst tmp
      dst="${constants.nixConfigDir}/users/${constants.user.name}/desktop/dms/settings.json"
      if [ -f "$HOME/.config/dms/settings.json" ]; then
        src="$HOME/.config/dms/settings.json"
      elif [ -f "$HOME/.config/DankMaterialShell/settings.json" ]; then
        src="$HOME/.config/DankMaterialShell/settings.json"
      else
        return 0
      fi
      tmp="$dst.tmp"
      jq -S . "$src" > "$tmp" && mv "$tmp" "$dst"
    }
    upfw() { cd ${constants.nixConfigDir} && sudo nixos-rebuild switch --flake .#framework13; }
    uphm() { cd ${constants.nixConfigDir} && dms-pull && home-manager switch --flake .#yhattori@framework13 -b backup && niri msg action load-config-file; }
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
      echo "  dms-pull        copy live DMS settings into the repo"
      echo "  upfw            rebuild system (nixos-rebuild)"
      echo "  uphm            rebuild home-manager (runs dms-pull first)"
      echo "  upall           upfw + uphm"
      echo "  update-bios     fwupdmgr update"
    }
  '';
}
