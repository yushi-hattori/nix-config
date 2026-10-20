# VS Code — GUI editor.
#
# Secondary editor (neovim is primary). Wrapped in an FHS environment so
# extensions/embedded toolchains work.
{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };
}
