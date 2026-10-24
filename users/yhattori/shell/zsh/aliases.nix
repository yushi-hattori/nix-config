# Zsh — general aliases + master alias index.
#
# Master index of every alias/function and where it lives, grouped by topic:
#
#   shell:
#     main          zellij attach --create main        shell/zellij.nix
#     ff            fastfetch                           shell/fastfetch.nix
#     cd            z (zoxide)                          shell/zoxide.nix
#     ls/ll/la/lt   eza (icons / long / all / tree)    cli/eza.nix
#   network:
#     wifi          nmtui-go                            cli/nmtui-go.nix
#     bt            bluetui                             cli/bluetui.nix
#   dev:
#     lg            lazygit                             dev/lazygit.nix
#     v / vi / vim  nvim                                editors/neovim.nix
#   ai:
#     oc            opencode                            ai/opencode.nix
#   python:
#     conda / mamba micromamba                          dev/mamba.nix
#     deeplearning  conda activate deeplearning         dev/mamba.nix
#   navigation:
#     repo          cd ~/Documents/repositories         (this file)
#     temp          cd ~/Downloads/temp                 (this file)
#     ..            cd ..                               (this file)
#
# Functions (multi-step, not aliases):
#   dms-pull           copy live DMS settings into repo      shell/zsh/functions.nix
#   openchamber-pull   copy live OpenChamber prefs into repo shell/zsh/functions.nix
#   upfw               rebuild system                        shell/zsh/functions.nix
#   uphm               rebuild home-manager                  shell/zsh/functions.nix
#   upall              upfw + uphm                           shell/zsh/functions.nix
#   update-bios        fwupdmgr update                       shell/zsh/functions.nix
#   help               print this alias/function list        shell/zsh/functions.nix
#
# This file only holds the directory-shortcut aliases; everything program-
# specific is declared next to its program (Nix merges them all together).
{ ... }:
{
  programs.zsh.shellAliases = {
    repo = "cd $HOME/Documents/repositories";
    temp = "cd $HOME/Downloads/temp";
    ".." = "cd ..";
  };
}
