{ lib, pkgs, ... }:
{
  # niri's XWayland integration (xwayland-satellite) doesn't paint RAIL
  # (seamless/RemoteApp) window content from FreeRDP — the window opens with
  # the right size/title but stays blank forever. Confirmed via a real X11
  # session (Xephyr) that FreeRDP/WinApps/the VM are all fine; this is a niri
  # xwayland-satellite limitation (it's already known to not respect some
  # X11 window properties: https://niri-wm.github.io/niri/Xwayland.html).
  # Running the RAIL session inside gamescope (a real nested Wayland
  # compositor with its own Xwayland) works around it.
  home.packages = [ pkgs.gamescope ];

  home.file.".local/bin/winapps-gamescope" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec gamescope -W 1920 -H 1080 --force-windows-fullscreen -- "$HOME/.local/bin/winapps" "$@"
    '';
  };

  # WinApps' setup.sh (re)generates these .desktop files, always pointing
  # Exec at ~/.local/bin/winapps directly, so re-point the RAIL ones (not
  # "windows", which is a full-desktop RDP session and already works fine)
  # at the gamescope wrapper on every activation. Idempotent: once patched,
  # "winapps " (with trailing space) no longer matches "winapps-gamescope ".
  home.activation.winappsGamescopeDesktopFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for app in cmd explorer powershell fusion-360 powershell-ide; do
      DESKTOP_FILE="$HOME/.local/share/applications/$app.desktop"
      if [ -f "$DESKTOP_FILE" ]; then
        run sed -i "s|Exec=$HOME/.local/bin/winapps |Exec=$HOME/.local/bin/winapps-gamescope |" "$DESKTOP_FILE"
      fi
    done
  '';

  # Generate ~/.config/winapps/winapps.conf on every activation. Everything
  # here is non-secret and declarative except RDP_PASS, which is read at
  # runtime from ~/nix-config/.env (gitignored) so the password never lands
  # in the Nix store or git history.
  home.activation.winappsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ENV_FILE="$HOME/nix-config/.env"
    if [ -f "$ENV_FILE" ]; then
      set -a
      source "$ENV_FILE"
      set +a
    fi

    run mkdir -p "$HOME/.config/winapps"
    run printf '%s\n' \
      'WAFLAVOR="libvirt"' \
      'VM_NAME="tinyWin11"' \
      'LIBVIRT_DEFAULT_URI="qemu:///system"' \
      'RDP_USER="Yushi"' \
      "RDP_PASS=\"$WINAPPS_RDP_PASS\"" \
      'RDP_DOMAIN=""' \
      'RDP_IP="192.168.122.159"' \
      'RDP_SCALE=100' \
      'RDP_FLAGS=""' \
      'MULTIMON="false"' \
      'DEBUG="false"' \
      'APP_SCAN_TIMEOUT="180"' \
      > "$HOME/.config/winapps/winapps.conf"
    run chmod 600 "$HOME/.config/winapps/winapps.conf"
  '';
}
