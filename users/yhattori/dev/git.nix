# git — version control.
#
# Identity and commit signing come from constants.user. delta is the diff
# highlighter (also used by lazygit's pager).
{ constants, ... }:
{
  programs.git = {
    enable = true;
    signing = {
      key = constants.user.gitKey;
      signByDefault = true;
    };
    settings = {
      user = {
        name = constants.user.fullName;
        email = constants.user.email;
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
}
