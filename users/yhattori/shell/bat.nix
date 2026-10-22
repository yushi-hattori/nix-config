# bat — prettier `cat`.
#
# Syntax-highlighted file viewer. fzf's preview uses it for file contents.
{ ... }:
{
  programs.bat = {
    enable = true;
  };
}
