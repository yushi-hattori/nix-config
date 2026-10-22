# btop — resource monitor.
#
# Terminal CPU/memory/process monitor with vim keybindings.
{ ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
    };
  };
}
