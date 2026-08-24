{ lib, ... }:
{
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
