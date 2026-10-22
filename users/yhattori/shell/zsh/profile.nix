# Zsh — login-shell profile (~/.zprofile).
#
# Runs once at login. getty autologs the user in on tty1; this launches the
# niri session there. The NIRI_SESSION_LAUNCHED guard is essential: niri-session
# re-execs itself through a login shell (`exec -l $SHELL`), which re-sources
# this file — without the guard it would recurse forever. Not exec'd: if niri
# fails we fall through to a plain shell on tty1.
{ ... }:
{
  programs.zsh.profileExtra = ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ] && [ -z "$NIRI_SESSION_LAUNCHED" ]; then
      export NIRI_SESSION_LAUNCHED=1
      niri-session
    fi
  '';
}
