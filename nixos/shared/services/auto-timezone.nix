# auto-timezone — set the system timezone from IP geolocation.
#
# Resolves the timezone from the public IP and repoints /etc/localtime, so the
# clock follows you when traveling. Runs at boot, after each rebuild, on
# network up, and on a periodic timer.
{ pkgs, ... }:
let
  dispatcher = pkgs.writeShellScript "auto-timezone-dispatcher" ''
    case "$2" in
      up) ;;
      *) exit 0 ;;
    esac
    ${pkgs.systemd}/bin/systemctl --no-block start auto-timezone.service
  '';
in
{
  systemd.services.auto-timezone = {
    description = "Set the system timezone from IP geolocation";
    wantedBy = [ "multi-user.target" ];
    after = [ "NetworkManager.service" ];
    restartTriggers = [ "/run/current-system" ];
    path = with pkgs; [
      coreutils
      curl
      gnugrep
    ];
    serviceConfig = {
      Type = "oneshot";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/etc" ];
      PrivateTmp = true;
    };
    script = ''
      zone="$(curl -fsS --max-time 6 'http://ip-api.com/line/?fields=timezone' 2>/dev/null || true)"

      case "$zone" in
        [A-Za-z0-9_+-]*/[A-Za-z0-9_+-]*) ;;
        *) zone="" ;;
      esac

      if [ -z "$zone" ]; then
        zone="$(
          curl -fsS --max-time 6 'https://ipwho.is/' 2>/dev/null \
            | grep -oE '"[A-Za-z0-9_+-]+/[A-Za-z0-9_+-]+"' \
            | head -n1 \
            | tr -d '"' || true
        )"
      fi

      case "$zone" in
        [A-Za-z0-9_+-]*/[A-Za-z0-9_+-]*) ;;
        *) exit 0 ;;
      esac

      want="/etc/zoneinfo/$zone"
      [ -e "$want" ] || exit 0

      [ "$(readlink /etc/localtime 2>/dev/null || true)" = "$want" ] && exit 0
      ln -sfn "$want" /etc/localtime || true
    '';
  };

  systemd.timers.auto-timezone = {
    description = "Periodic auto timezone check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:00,10,20,30,40,50:00";
      RandomizedDelaySec = "2m";
    };
  };

  networking.networkmanager.dispatcherScripts = [
    {
      source = dispatcher;
      type = "basic";
    }
  ];
}
