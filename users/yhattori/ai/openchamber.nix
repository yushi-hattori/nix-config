# OpenChamber Desktop — the Electron GUI for OpenCode sessions.
#
# Ships the desktop entry (openchamber.desktop) + icon so it shows up in the
# launcher. Package comes from the openchamber overlay (overlays/openchamber.nix).
#
# OpenChamber's user profile (~/.config/openchamber/preferences.json) is kept
# declarative: `openchamber-pull` (shell/zsh/functions.nix) copies the live
# file into ./openchamber/preferences.json before every `uphm`, and the
# activation below writes it back out as a real (writable) file. We can't use a
# home-manager symlink here because OpenChamber rewrites it at runtime.
#
# Only `preferences.json` (the user profile) is declared. The sibling
# `settings.json` is instance state (projects + lastOpenedAt, window state) and
# `relay-identity.json` / `git-credential-endpoint.json` hold secrets, so those
# stay live-only.
{ pkgs, lib, ... }:
let
  preferences = builtins.fromJSON (builtins.readFile ./openchamber/preferences.json);

  # Declarative overrides, re-applied on top of the pulled profile after every
  # `uphm` so they survive the live->repo round-trip. Add any key you want
  # pinned here; everything else is taken verbatim from the pull.
  overrides = {
    reportUsage = false; # never send usage/telemetry
  };

  # Same field set as the pull, but with each override's `value` forced while
  # its `updatedAt`/`surfaces` are preserved.
  mergedFields =
    preferences.fields
    // builtins.mapAttrs
      (name: value: (preferences.fields.${name} or {}) // { value = value; })
      overrides;

  mergedPreferences = preferences // { fields = mergedFields; };
in
{
  home.packages = [ pkgs.openchamber-desktop ];

  home.activation.openchamber-preferences = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -D -m644 \
      ${pkgs.writeText "openchamber-preferences.json" (builtins.toJSON mergedPreferences)} \
      "$HOME/.config/openchamber/preferences.json"
  '';
}
