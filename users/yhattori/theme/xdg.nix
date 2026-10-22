# xdg — XDG user directories.
#
# Creates/uses the standard ~/Documents, ~/Downloads, ~/Pictures, ~/Videos etc.
# and exports them to the session. (Default-app associations are left out for
# now; they referenced apps that were dropped.)
{ ... }:
{
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };
}
