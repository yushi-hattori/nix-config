{
  pkgs,
  ...
}:

let
  # NetworkManager dispatcher hook: kick the service whenever a connection
  # becomes active. This covers boot, switching networks while traveling, and
  # reconnects after suspend/resume. The service is a plain oneshot that goes
  # inactive after each run, so every "up" event actually re-runs the lookup.
  dispatcher = pkgs.writeShellScript "auto-timezone-dispatcher" ''
    case "$2" in
      up) ;;
      *) exit 0 ;;
    esac
    ${pkgs.systemd}/bin/systemctl --no-block start auto-timezone.service
  '';
in
{
  # ─── Auto timezone — set the system timezone from IP geolocation ─────────────
  #
  # The fallback zone (America/Los_Angeles) is hard-coded in the common NixOS
  # module, which means it has to be edited by hand whenever traveling across
  # timezones. This instead resolves the current timezone from the public IP and
  # repoints /etc/localtime, so the clock follows you.
  #
  # Why not `timedatectl set-timezone`? NixOS bakes environment.etc files into a
  # read-only /nix/store path and symlinks /etc/static there. timedated is
  # pointed at /etc/static/localtime (see SYSTEMD_ETC_LOCALTIME), so every
  # timedatectl attempt fails with "Read-only file system". What the actual
  # system clock reads is the /etc/localtime symlink (in the writable /etc), so
  # we repoint that directly — the standard runtime workaround on NixOS.
  #
  # NixOS re-applies the fallback zone on every boot and every rebuild. The
  # service therefore also runs at boot (multi-user.target), is restarted by
  # systemd whenever /run/current-system changes (i.e. after each
  # `nixos-rebuild switch`, so the zone fixes itself right after an update),
  # and the timer + dispatcher catch anything else.
  #
  # Providers (first that answers wins):
  #   - ip-api.com   plain-text timezone, free for non-commercial use
  #   - ipwho.is     HTTPS JSON fallback (ip-api.com free tier is HTTP-only)

  systemd.services.auto-timezone = {
    description = "Set the system timezone from IP geolocation";
    wantedBy = [ "multi-user.target" ];
    after = [ "NetworkManager.service" ];
    # Restart after every nixos-rebuild switch so the zone isn't left on the
    # hard-coded fallback that activation re-applies.
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

      # Only trust a bare "Region/City" answer — anything else (an HTML error
      # page, a proxy message, …) is discarded before it reaches the clock.
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
        *) exit 0 ;; # offline or rate limited — leave the clock alone
      esac

      # The zone must actually exist on this system (also guards against a
      # garbage provider answer sneaking past the pattern check above).
      want="/etc/zoneinfo/$zone"
      [ -e "$want" ] || exit 0

      # Apply only if it differs from what the clock currently uses.
      [ "$(readlink /etc/localtime 2>/dev/null || true)" = "$want" ] && exit 0
      ln -sfn "$want" /etc/localtime || true
    '';
  };

  # Safety net: re-check periodically in case the network event was missed
  # (e.g. after a rebuild reset the zone while already connected, or the
  # restartTriggers above didn't fire).
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
