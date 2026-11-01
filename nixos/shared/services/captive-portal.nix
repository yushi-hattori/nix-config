# captive-portal — open the login page when a network has a captive portal.
#
# NetworkManager's connectivity check already detects portals (state flips to
# "portal"), but neither niri nor DMS reacts to it. This dispatcher opens the
# user's default browser (zen) to a plain-HTTP URL, which the portal's captive
# firewall redirects to its login page. neverssl.com exists purely to be plain
# HTTP for this purpose.
{ constants, pkgs, ... }:
let
  user = constants.user.name;
  dispatcher = pkgs.writeShellScript "captive-portal-dispatcher" ''
    # Only act on connectivity changes into the "portal" state. A `basic`-type
    # dispatcher receives two args: $1 = iface (empty for connectivity-change),
    # $2 = action. The new connectivity state arrives in the CONNECTIVITY_STATE
    # env var (uppercase: NONE, PORTAL, LIMITED, FULL, UNKNOWN).
    [ "$2" = "connectivity-change" ] || exit 0
    [ "$CONNECTIVITY_STATE" = "PORTAL" ] || exit 0

    uid="$(${pkgs.coreutils}/bin/id -u '${user}')" || exit 0
    export XDG_RUNTIME_DIR="/run/user/$uid"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

    # Find niri's Wayland socket so the browser can actually display.
    for sock in "$XDG_RUNTIME_DIR"/wayland-*; do
      [ -S "$sock" ] || continue
      export WAYLAND_DISPLAY="''${sock##*/}"
      break
    done

    # The dispatcher runs as root; relaunch as the user with their session env.
    # gio open resolves x-scheme-handler/http (already pinned to zen) and spawns
    # the browser.
    ${pkgs.util-linux}/bin/runuser -u '${user}' -- \
      ${pkgs.coreutils}/bin/env \
        XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
        WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
        ${pkgs.glib}/bin/gio open 'http://neverssl.com' >/dev/null 2>&1 || true
  '';
in
{
  networking.networkmanager.dispatcherScripts = [
    { source = dispatcher; type = "basic"; }
  ];
}
