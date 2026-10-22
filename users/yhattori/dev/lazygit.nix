# lazygit — git TUI.
#
# The `lg` alias. Uses delta for its diff pager.
{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        diffRenderers = [
          {
            colorArg = "always";
            command = "delta --color-only --dark --paging=never";
          }
        ];
      };
    };
  };

  programs.zsh.shellAliases.lg = "lazygit";
}
