{ userConfig, ... }:
{
  # Install git via home-manager module
  programs.git = {
    enable = true;
    signing = {
      key = userConfig.gitKey;
      signByDefault = true;
    };
    settings = {
      user = {
        name = userConfig.fullName;
        email = userConfig.email;
      };
      pull.rebase = "true";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      keep-plus-minus-markers = true;
      light = false;
      line-numbers = true;
      navigate = true;
      width = 280;
    };
  };

  # Enable catppuccin theming for git delta
  catppuccin.delta.enable = true;
}
